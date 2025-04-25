ARG RUBY_VERSION=3.4.3
ARG BUN_VERSION=1.2.8
ARG DOCKER_UID=1000
ARG DOCKER_USER=main
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=group
ARG GITHUB_ACTIONS=""

# Bun JS runtime layer
FROM --platform=$BUILDPLATFORM oven/bun:alpine AS bun

# Development environment
FROM ruby:$RUBY_VERSION-alpine3.21 AS development
ARG COMMIT_HASH
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ENV COMMIT_HASH=${COMMIT_HASH}
ENV TZ=UTC
ENV HOME=/main/
WORKDIR /main/
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        build-base \
        chromium-chromedriver \
        curl-dev \
        fontconfig \
        g++ \
        gcc \
        git \
        libc-dev \
        linux-headers \
        libpq-dev \
        libxml2-dev \
        make \
        postgresql-client \
        tzdata \
        yaml-dev \
        chromium
COPY Gemfile Gemfile.lock /main/
RUN gem install bundler && \
    bundle install --gemfile /main/Gemfile --jobs 32
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
COPY bun.config.js bun.lock package.json /main/
RUN bun install
RUN rm -rf /var/cache/apk/*
RUN if [ -z "$GITHUB_ACTIONS" ]; then \
    addgroup -g ${DOCKER_GID} ${DOCKER_GROUP} && \
    adduser -D -u ${DOCKER_UID} -G ${DOCKER_GROUP} -h /home/${DOCKER_USER} ${DOCKER_USER} && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main; \
fi && \
chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main
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
