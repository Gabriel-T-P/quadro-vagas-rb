FROM ruby:3.4.2

ENV INSTALL_PATH /opt/app

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  locales \
  postgresql-client \
  curl \
  && locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g corepack && corepack enable && corepack prepare yarn@stable --activate

RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY . .

EXPOSE 3000

CMD ["bin/dev"]
