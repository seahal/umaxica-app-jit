ARG RUBY_VERSION=3.4.2
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
ARG DOCKER_USER=developer
ARG DOCKER_GROUP=developer

# For Developing Environment
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
RUN apt-get update -qq && \
    apt-get upgrade -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 postgresql-client libvips wget zsh bash && \
#    apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 libgtk2.0-0 libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1 libasound2  && \
#    apt-get install -y chromium chromium-chromedriver python3 python3-dev py3-pip && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
COPY Gemfile Gemfile.lock /main/
RUN bundle install
COPY . /main
# ユーザーとグループを作成
RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
    useradd -l -u ${DOCKER_UID} -g ${DOCKER_GROUP} -m ${DOCKER_USER}
# ディレクトリの所有権を設定
RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main
# 作成したユーザーに切り替え
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
    bundle install --without test development && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
COPY . /main
# change user & group id
RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
    useradd -l ${DOCKER_USER} -u ${DOCKER_UID} -g ${DOCKER_GROUP} && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main
# chown?
USER ${DOCKER_USER}
