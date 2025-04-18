ARG RUBY_VERSION=3.4.3
ARG BUN_VERSION=1.2.8
ARG DOCKER_UID=1000
ARG DOCKER_USER=main
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=group
ARG GITHUB_ACTIONS=""

# For Developing Environment
FROM ruby:$RUBY_VERSION-bookworm AS development
ARG COMMIT_HASH
ARG DOCKER_UID
ARG DOCKER_GID
ARG DOCKER_USER
ARG DOCKER_GROUP
ARG BUN_VERSION
ENV COMMIT_HASH=${COMMIT_HASH}
ENV TZ=UTC
ENV HOME=/main/
WORKDIR /main/
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client unzip bash curl npm
COPY Gemfile Gemfile.lock /main/
RUN gem install bundler
RUN bundle install --gemfile /main/Gemfile --jobs 4
#RUN curl -fsSL https://bun.sh/install | bash
#ENV PATH="/main/.bun/bin:$PATH"
RUN npm install -g bun
COPY bun.config.js bun.lock package.json /main/
RUN bun install
RUN if [ -z "$GITHUB_ACTIONS" ]; then \
      groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
      useradd -l -u ${DOCKER_UID} -g ${DOCKER_GROUP} -m ${DOCKER_USER} && \
      chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main; \
    fi
RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main
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
