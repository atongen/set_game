FROM alpine:3.2
MAINTAINER Andrew Tongen atongen@gmail.com

RUN apk add --update \
  ca-certificates \
  build-base \
  ruby \
  ruby-bundler \
  ruby-dev \
  git \
  nodejs \
  openssl \
  openssl-dev && \
  rm -fr /usr/share/ri && \
  rm -fr /var/cache/apk/*

COPY config/docker /

RUN export uid=1000 gid=1000 && \
  mkdir -p /home/app && \
  echo "app:x:${uid}:${gid}:app,,,:/home/app:/bin/false" >> /etc/passwd && \
  echo "app:x:${uid}:" >> /etc/group

ENV HOME /home/app

ADD . /home/app
RUN chown -R app:app /home/app

USER app
WORKDIR /home/app
RUN bundle install --deployment --without test development doc
RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["bundle", "exec", "thin", "-e", "production", "start"]
