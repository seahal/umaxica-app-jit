# syntax=docker/dockerfile:1

# ============================================================================
# Shared build arguments
# ============================================================================
ARG RUBY_VERSION=4.0
ARG BUN_VERSION=1.3.5
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
ARG DOCKER_USER=jit
ARG DOCKER_GROUP=umaxica
ARG GITHUB_ACTIONS=""

# ============================================================================
# Production image (multi-stage build)
# ============================================================================
FROM ruby:${RUBY_VERSION}-slim-trixie AS production-base
SHELL ["/bin/bash", "-eu", "-o", "pipefail", "-c"]
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ENV HOME=/home/${DOCKER_USER}
ENV APP_HOME=${HOME}/main
ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle/.bundle \
    BUNDLE_FROZEN=1 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

WORKDIR ${APP_HOME}

RUN if ! getent group "${DOCKER_GROUP}" >/dev/null; then \
    groupadd --gid "${DOCKER_GID}" "${DOCKER_GROUP}"; \
    fi \
    && if ! id -u "${DOCKER_USER}" >/dev/null 2>&1; then \
    useradd --uid "${DOCKER_UID}" --gid "${DOCKER_GROUP}" --home "${HOME}" --shell /usr/sbin/nologin "${DOCKER_USER}"; \
    fi \
    && mkdir -p "${APP_HOME}" "${HOME}" \
    && chown -R "${DOCKER_UID}:${DOCKER_GID}" "${HOME}"

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpq5 \
    libvips \
    libyaml-0-2 \
    tzdata \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*


# ============================================================================
# ============================================================================

FROM production-base AS production-build
# Install build tools required for gems
ARG DOCKER_UID
ARG DOCKER_GID
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips-dev \
    libyaml-dev \
    pkg-config \
    unzip \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/usr/local/bundle,uid=${DOCKER_UID},gid=${DOCKER_GID} \
    --mount=type=cache,target=/tmp/bundle-cache,uid=${DOCKER_UID},gid=${DOCKER_GID} \
    bundle config set --local cache_path /tmp/bundle-cache \
    && bundle install --jobs "${BUNDLE_JOBS}" --retry "${BUNDLE_RETRY}" \
    && bundle exec bootsnap precompile --gemfile \
    && bundle config set --local without 'development test' \
    && bundle clean --force \
    && rm -rf /usr/local/bundle/cache


COPY . .

RUN install -d tmp/pids log \
    && rm -rf tmp/cache \
    && find log -type f -exec truncate -s 0 {} + \
    && rm -f tmp/pids/server.pid

# ============================================================================
# ============================================================================
FROM production-base AS production
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ENV PORT=3000 \
    RUBY_YJIT_ENABLE=1 \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=true \
    PATH=/usr/local/bundle/bin:${PATH}

COPY --from=production-build --chown=${DOCKER_UID}:${DOCKER_GID} /usr/local/bundle /usr/local/bundle
COPY --from=production-build --chown=${DOCKER_UID}:${DOCKER_GID} ${APP_HOME} ${APP_HOME}

RUN chown -R ${DOCKER_UID}:${DOCKER_GID} tmp log

USER ${DOCKER_USER}

EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "--port", "8080"]

# ============================================================================
# Development image (used by docker compose)
# ============================================================================
FROM ruby:${RUBY_VERSION}-trixie AS development-base
SHELL ["/bin/bash", "-eu", "-o", "pipefail", "-c"]
ENV TZ=UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    BUNDLE_FORCE_RUBY_PLATFORM=1

# hadolint ignore=DL3008
RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
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
    zlib1g-dev \
    graphviz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# ============================================================================
# ============================================================================
FROM development-base AS development
SHELL ["/bin/bash", "-eu", "-o", "pipefail", "-c"]
ARG COMMIT_HASH
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ARG BUN_VERSION
ARG GITHUB_ACTIONS
ENV COMMIT_HASH="${COMMIT_HASH}"
ENV HOME=/home/jit
ENV BUN_INSTALL=/usr/local
WORKDIR /home/jit/workspace

# hadolint ignore=DL3008
RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
    bash \
    bat \
    entr \
    fd-find \
    fontconfig \
    fzf \
    htop \
    iproute2 \
    jq \
    yq \
    lsb-release \
    ncdu \
    npm \
    openssl \
    ripgrep \
    silversearcher-ag \
    sudo \
    tig \
    tmux \
    tree \
    unzip \
    vim \
    watch \
    wget \
    zip \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

COPY --chown=${DOCKER_UID}:${DOCKER_GID} Gemfile Gemfile.lock package.json bun.lock ./

RUN --mount=type=cache,target=/tmp/bun-cache,uid=${DOCKER_UID},gid=${DOCKER_GID} \
    if curl -fsSL --retry 5 --retry-delay 3 --retry-max-time 120 https://bun.sh/install -o /tmp/bun.sh \
    && bash /tmp/bun.sh "bun-v${BUN_VERSION}"; then \
    echo "Bun installed successfully"; \
    else \
    echo "Bun installation failed, trying direct download..." \
    && curl -fsSL --retry 5 --retry-delay 3 --retry-max-time 120 \
    "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-x64.zip" -o /tmp/bun.zip \
    && unzip -q /tmp/bun.zip -d /tmp \
    && mv /tmp/bun-linux-x64/bun /usr/local/bin/bun \
    && chmod +x /usr/local/bin/bun \
    && rm -rf /tmp/bun.zip /tmp/bun-linux-x64; \
    fi

RUN if [ -z "${GITHUB_ACTIONS}" ]; then \
    groupadd -g "${DOCKER_GID}" "${DOCKER_GROUP}"; \
    useradd -l -u "${DOCKER_UID}" -g "${DOCKER_GROUP}" -m -s /bin/bash "${DOCKER_USER}"; \
    echo "${DOCKER_USER}:${DOCKER_USER_PASSWORD:-devpassword}" | chpasswd; \
    echo "${DOCKER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    chown -R "${DOCKER_UID}:${DOCKER_GID}" "${HOME}"; \
    else \
    chown -R "${DOCKER_UID}:${DOCKER_GID}" "${HOME}"; \
    fi

# Install pnpm for development use only (available by default on PATH).
RUN npm install -g pnpm

USER ${DOCKER_USER}
