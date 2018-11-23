FROM ruby:2.5.3-alpine3.8

RUN apk add --update \
  ca-certificates \
  build-base \
  ruby \
  ruby-bundler \
  ruby-io-console \
  ruby-dev \
  git \
  nodejs \
  openssl \
  openssl-dev && \
  rm -fr /usr/share/ri && \
  rm -fr /var/cache/apk/*

COPY config/docker /
COPY . /home/app

ENV HOME /home/app
WORKDIR /home/app
RUN bundle install --deployment --without test development doc
RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["bundle", "exec", "thin", "-e", "production", "start"]
