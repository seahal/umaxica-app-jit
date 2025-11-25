# syntax=docker/dockerfile:1

# ============================================================================
# Shared build arguments
# ============================================================================
ARG RUBY_VERSION=3.5.0-preview1
ARG BUN_VERSION=1.3.3
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
ARG DOCKER_USER=jit
ARG DOCKER_GROUP=umaxica
ARG GITHUB_ACTIONS=""
ARG CLOUDFLARE_R2_TOKEN=""

# ============================================================================
# Production image (multi-stage build)
# ============================================================================
FROM ruby:${RUBY_VERSION}-slim-trixie AS production-base
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
SHELL ["/bin/bash", "-eu", "-o", "pipefail", "-c"]
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

ARG BUN_VERSION
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips-dev \
    libyaml-dev \
    nodejs \
    npm \
    pkg-config \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@"${BUN_VERSION}" \
    && npm cache clean --force

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs ${BUNDLE_JOBS} --retry ${BUNDLE_RETRY} \
    && bundle exec bootsnap precompile --gemfile \
    && bundle config set --local without 'development test' \
    && bundle clean --force \
    && rm -rf /usr/local/bundle/cache

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile \
    && rm -rf /root/.bun/cache

COPY . .

RUN bun run build \
    && rm -rf node_modules \
    && install -d tmp/pids log \
    && rm -rf tmp/cache \
    && find log -type f -exec truncate -s 0 {} + \
    && rm -f tmp/pids/server.pid

# ============================================================================
# ============================================================================
FROM production-base AS production
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP

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
    nodejs \
    npm \
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
ARG COMMIT_HASH
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ARG BUN_VERSION
ARG GITHUB_ACTIONS
ENV COMMIT_HASH="${COMMIT_HASH}"
ENV HOME=/home/jit
WORKDIR /home/jit/workspace

RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
    bash \
    zsh \
    iproute2 \
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
    libxtst6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

COPY --chown=${DOCKER_UID}:${DOCKER_GID} Gemfile Gemfile.lock package.json bun.lock ./

RUN npm install -g bun@"${BUN_VERSION}" \
    && npm cache clean --force

RUN rm -rf /home/jit/.npm

RUN if [ -z "${GITHUB_ACTIONS}" ]; then \
    groupadd -g "${DOCKER_GID}" "${DOCKER_GROUP}"; \
    useradd -u "${DOCKER_UID}" -g "${DOCKER_GROUP}" -m -s /bin/bash "${DOCKER_USER}"; \
    echo "${DOCKER_USER}:hogehoge" | chpasswd; \
    echo "${DOCKER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    chown -R "${DOCKER_UID}:${DOCKER_GID}" ${HOME}; \
    else \
    chown -R "${DOCKER_UID}:${DOCKER_GID}" ${HOME}; \
    fi

USER ${DOCKER_USER}
