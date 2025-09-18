# Build arguments
ARG RUBY_VERSION=3.4.6
ARG BUN_VERSION=1.2.22
ARG NODE_VERSION=22
ARG DOCKER_UID=1000
ARG DOCKER_USER=main
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=group
ARG GITHUB_ACTIONS=""

# Base image with common dependencies
FROM ruby:$RUBY_VERSION-trixie AS base
ENV TZ=UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    BUNDLE_FORCE_RUBY_PLATFORM=1

# Install common system dependencies with security updates
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
    unzip \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

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
# Install development-specific dependencies in single layer
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    bash \
    dbus \
    fontconfig \
    lsb-release \
    openssl \
    sudo \
    udev \
    unzip \
    xserver-xorg-core \
    xvfb \
    zip \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnss3 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libsecret-1-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxkbcommon0 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*
# Install Bun consistently with asset_builder stage
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}" && \
    mv ~/.bun/bin/bun /usr/local/bin/bun && \
    chmod +x /usr/local/bin/bun
# Copy dependency files first for better caching
COPY --chown=${DOCKER_USER}:${DOCKER_GROUP} ../Gemfile ../Gemfile.lock ../package.json ../bun.lock /main
# Install dependencies
RUN gem install bundler && \
    bundle config set --local path /main/vendor/bundle && \
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