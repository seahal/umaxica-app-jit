ARG RUBY_VERSION=3.4.2

FROM ruby:$RUBY_VERSION-bookworm AS development
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH}
ENV TZ=UTC
ENV HOME=/main
#RUN groupadd -r lirantal && useradd -r -s /bin/false -g lirantal lirantal
RUN mkdir /main
WORKDIR /main
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
COPY Gemfile Gemfile.lock /main/
RUN bundle install


FROM ruby:$RUBY_VERSION-bookworm AS production
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    TZ=UTC
ARG DOCKER_GID=2000
ARG DOCKER_GROUP=g1
ARG DOCKER_UID=2000
ARG DOCKER_USER=u1
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH}
RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP}
WORKDIR /main
COPY Gemfile Gemfile.lock /main/
RUN bundle install && \
   rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
   bundle exec bootsnap precompile --gemfile
ADD ./ /main
RUN useradd ${DOCKER_USER} -u ${DOCKER_UID} -g ${DOCKER_GROUP}
RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} db log storage tmp
USER ${DOCKER_USER}