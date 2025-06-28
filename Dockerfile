# Build arguments
ARG RUBY_VERSION=3.4.4
ARG BUN_VERSION=1.2.17
ARG NODE_VERSION=22
ARG DOCKER_UID=1000
ARG DOCKER_USER=main
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=group
ARG GITHUB_ACTIONS=""

# Base image with common dependencies
FROM ruby:$RUBY_VERSION-bookworm AS base
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive

# Install common system dependencies
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        gnupg \
        libpq-dev \
        libvips \
        libxml2-dev \
        libyaml-dev \
        postgresql-client \
        tzdata \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Development environment
FROM base AS development
ARG COMMIT_HASH
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ARG BUN_VERSION
ENV COMMIT_HASH=${COMMIT_HASH}
ENV HOME=/main/
WORKDIR /main/
# Install development-specific dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        bash \
        dbus \
        lsb-release \
        openssl \
        sudo \
        udev \
        xserver-xorg-core \
        xvfb && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
# Install Node.js and Bun
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g bun@${BUN_VERSION} && \
    rm -rf /var/lib/apt/lists/*
# Copy dependency files first for better caching
COPY Gemfile Gemfile.lock package.json bun.lock /main/
# Install dependencies
RUN gem install bundler && \
    bundle install --gemfile /main/Gemfile --jobs $(nproc)
# Create user and set permissions
RUN if [ -z "$GITHUB_ACTIONS" ]; then \
        groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
        useradd -u ${DOCKER_UID} -g ${DOCKER_GROUP} -m -s /bin/bash ${DOCKER_USER} && \
        echo "${DOCKER_USER}:hogehoge" | chpasswd && \
        echo "${DOCKER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
        chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main; \
    else \
        chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main; \
    fi
USER ${DOCKER_USER}

# Asset builder stage using Bun
FROM base AS asset_builder
ARG BUN_VERSION
WORKDIR /app

# Install Bun more efficiently
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}" && \
    ln -s ~/.bun/bin/bun /usr/local/bin/bun

# Copy package files for dependency caching
COPY package.json bun.lock* /app/

# Install JavaScript dependencies
RUN bun install --frozen-lockfile --production

# Copy only necessary source files for building
COPY app/javascript/ /app/app/javascript/
COPY bun.config.js /app/

# Build assets
RUN bun run build

# Ruby dependencies builder
FROM base AS ruby_builder
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH}
ENV RAILS_ENV="production"
ENV BUNDLE_DEPLOYMENT="1"
ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_WITHOUT="development:test"

WORKDIR /app

# Install additional build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        pkg-config && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy and install Ruby dependencies
COPY Gemfile Gemfile.lock /app/
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs=$(nproc) --retry=3 && \
    bundle clean --force && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git "${BUNDLE_PATH}"/ruby/*/gems/*/ext

# Production environment
FROM ruby:$RUBY_VERSION-slim-bookworm AS production

# Build arguments and environment variables
ARG COMMIT_HASH
ARG DOCKER_UID=1001
ARG DOCKER_GID=1001
ARG DOCKER_USER=rails
ARG DOCKER_GROUP=rails

# Set environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_LOG_TO_STDOUT="true" \
    TZ=UTC \
    COMMIT_HASH=${COMMIT_HASH} \
    LD_PRELOAD="libjemalloc.so.2" \
    MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true"

# Create non-root user first
RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
    useradd -u ${DOCKER_UID} -g ${DOCKER_GROUP} -m -s /bin/bash ${DOCKER_USER}

WORKDIR /rails

# Install minimal runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        libjemalloc2 \
        libpq5 \
        libvips42 \
        postgresql-client \
        tzdata && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy built gems from ruby_builder
COPY --from=ruby_builder --chown=${DOCKER_USER}:${DOCKER_GROUP} /usr/local/bundle /usr/local/bundle

# Copy built assets from asset_builder
COPY --from=asset_builder --chown=${DOCKER_USER}:${DOCKER_GROUP} /app/app/assets/builds /rails/app/assets/builds

# Copy application code
COPY --chown=${DOCKER_USER}:${DOCKER_GROUP} . /rails/

# Create necessary directories and set permissions
RUN mkdir -p /rails/tmp/pids /rails/log /rails/storage && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /rails && \
    chmod +x /rails/bin/*

# Switch to non-root user for asset precompilation and runtime
USER ${DOCKER_USER}

# Precompile assets as non-root user
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/api/app/v1/healths || exit 1

# Expose port
EXPOSE 3000

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
