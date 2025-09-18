ARG RUBY_VERSION=3.4.6

FROM ruby:${RUBY_VERSION}-slim-trixie AS base

ENV APP_HOME=/app \
    LANG=C.UTF-8 \
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

RUN groupadd --system rails \
    && useradd --system --gid rails --home ${APP_HOME} --shell /usr/sbin/nologin rails

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpq5 \
    libvips \
    libyaml-0-2 \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

FROM base AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    libvips-dev \
    libyaml-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs ${BUNDLE_JOBS} --retry ${BUNDLE_RETRY} \
    && bundle exec bootsnap precompile --gemfile \
    && bundle clean --force \
    && rm -rf /usr/local/bundle/cache

COPY . .

RUN mkdir -p tmp/pids log \
    && rm -rf tmp/cache \
    && find log -type f -exec truncate -s 0 {} + \
    && rm -f tmp/pids/server.pid

FROM base AS runtime

ENV PORT=8080 \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=true \
    PATH=/usr/local/bundle/bin:${PATH}

COPY --from=build --chown=rails:rails /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /app /app

USER rails

EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
