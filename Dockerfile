ARG RUBY_VERSION=3.4.2
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
ARG DOCKER_USER=developer
ARG DOCKER_GROUP=developer

FROM ruby:$RUBY_VERSION-bookworm AS development
ARG COMMIT_HASH
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ENV COMMIT_HASH=${COMMIT_HASH}
ENV TZ=UTC
ENV HOME=/main
WORKDIR /main

# ユーザーとグループを作成
RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
    useradd -l -u ${DOCKER_UID} -g ${DOCKER_GROUP} -m ${DOCKER_USER}

# バージョンを固定
RUN apt-get update -qq && \
    apt-get upgrade -qq && \
    apt-get install --no-install-recommends -y \
    curl=7.88.1-10+deb12u5 \
    libjemalloc2=5.3.0-1 \
    postgresql-client=15+deb12u1 \
    libvips=8.14.2-1+b1 \
    wget=1.21.3-1+b1 \
    zsh=5.9-4+deb12u1 \
    bash=5.2.15-2+deb12u1 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock /main/
RUN bundle install
COPY . /main/

# ディレクトリの所有権を設定
RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main

# 作成したユーザーに切り替え
USER ${DOCKER_USER}

FROM ruby:$RUBY_VERSION-slim AS production
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    TZ=UTC
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=developer
ARG DOCKER_UID=1000
ARG DOCKER_USER=developer
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH}

# バージョンを固定
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    postgresql-client=15+deb12u1 \
    libvips=8.14.2-1+b1 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP}
WORKDIR /main
COPY Gemfile Gemfile.lock /main/
RUN bundle install && \
   rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . /main
# -l フラグを追加してログインディレクトリを作成しない
RUN useradd -l ${DOCKER_USER} -u ${DOCKER_UID} -g ${DOCKER_GROUP} && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main
USER ${DOCKER_USER}