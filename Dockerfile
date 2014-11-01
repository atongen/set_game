# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-ruby19:0.9.14
MAINTAINER Andrew Tongen "atongen@gmail.com"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN apt-get update -qq
RUN apt-get -qy install openjdk-7-jdk

ADD . /home/app
WORKDIR /home/app
RUN chown -R app:app /home/app
RUN sudo -u app bundle install --deployment --without test development doc
RUN sudo -u app RAILS_ENV=production bundle exec rake assets:precompile

RUN mkdir /etc/service/app
ADD bin/run /etc/service/app/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 3000
