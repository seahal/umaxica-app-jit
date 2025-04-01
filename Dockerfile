ARG RUBY_VERSION=3.4.2
ARG BUN_VERSION=1.2.7
ARG DOCKER_GID=1000
ARG DOCKER_GROUP=developer
ARG DOCKER_UID=1000
ARG DOCKER_USER=developer

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
ENV HOME=/main
WORKDIR /main
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client unzip sudo
RUN apt install chromium
#RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
#RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
#RUN apt install google-chrome-stable
#RUN apt-get update -qq && \
#    apt-get upgrade -qq && \
#    apt-get install --no-install-recommends -y curl libjemalloc2 postgresql-client libvips wget zsh bash unzip fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 libgtk2.0-0 libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1 libasound2 gnupg && \
#    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
#    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
#    apt-get install -y google-chrome-stable # && \
#    # ChromeDriver のインストール
#    CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1) && \
#    CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION") && \
#    wget -q "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" && \
#    unzip chromedriver_linux64.zip -d /usr/local/bin && \
#    chmod +x /usr/local/bin/chromedriver && \
#    rm chromedriver_linux64.zip && \
    # キャッシュをクリーンアップ
    #rm -rf /var/lib/apt/lists /var/cache/apt/archives
#COPY Gemfile Gemfile.lock /main/
#RUN bundle install
#COPY . /main
#RUN groupadd -g ${DOCKER_GID} ${DOCKER_GROUP} && \
#    useradd -l -u ${DOCKER_UID} -g ${DOCKER_GROUP} -m ${DOCKER_USER}
#RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /main
#RUN chsh -s /bin/bash
#ENV SHELL /bin/bash
#RUN curl https://bun.sh/install | bash
#ENV PATH="/main/.bun/bin:$PATH"
#USER ${DOCKER_USER}


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
