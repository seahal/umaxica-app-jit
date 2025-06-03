ARG RUBY_VERSION=3.4.4
ARG BUN_VERSION=1.2.8
ARG DOCKER_UID=1000
ARG DOCKER_USER=main
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=group
ARG GITHUB_ACTIONS=""

# Development environment
FROM ruby:$RUBY_VERSION-bookworm AS development
ARG COMMIT_HASH
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ENV COMMIT_HASH=${COMMIT_HASH}
ENV TZ=UTC
ENV HOME=/main/
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /main/

# Install system dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        bash \
        build-essential \
        curl \
        git \
        libpq-dev \
        libxml2-dev \
        libyaml-dev \
        libvips \
        postgresql-client \
        tzdata \
        zlib1g-dev \
        xvfb \
        xserver-xorg-core \
        dbus \
        udev \
        openssl \
        sudo \
        ca-certificates \
        gnupg \
        lsb-release && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install Node.js and Bun
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g bun@${BUN_VERSION}

# Copy dependency files
COPY Gemfile Gemfile.lock package.json bun.lock /main/

# Install Ruby and Node.js dependencies
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


# For Production Environment
FROM ruby:$RUBY_VERSION-slim-bookworm AS production
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    TZ=UTC
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=production
ARG DOCKER_UID=1000
ARG DOCKER_USER=production
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH}
RUN apt-get update -qq && \
    apt-get upgrade -qq && \
    apt-get install --no-install-recommends -y build-essential git curl libjemalloc2 postgresql-client libvips libpq-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
WORKDIR /main
COPY Gemfile Gemfile.lock /main/
RUN bundle config set without 'test development' && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
COPY . /main
# change user & group id
RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
    useradd -l ${DOCKER_USER} -u ${DOCKER_UID} -g ${DOCKER_GROUP} && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main
# chown?
USER ${DOCKER_USER}
