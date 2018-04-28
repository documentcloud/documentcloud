FROM ruby:2.3.5

MAINTAINER Ted Han <ted@documentcloud.org>




# Install OS dependencies
RUN apt-get update
ADD ./config/server/scripts /setup
RUN /bin/bash -c /setup/setup_minimal_dependencies.sh


# Install Ruby dependencies
ADD Gemfile /documentcloud/Gemfile
ADD Gemfile.lock /documentcloud/Gemfile.lock

WORKDIR /documentcloud

RUN bundle install --without="pdf_processing"

# If runtime config is not copied in, default to running in
# Development mode (see config/cloud_crowd/* ).
ENV RAILS_ENV development
ENV CLOUD_CROWD_SERVER_HOST cloud_crowd_server
ENV CLOUD_CROWD_SERVER_PORT 8080


EXPOSE 8765

ADD . /documentcloud


# To run in other environments, use Docker Volumes to
# Copy configuration into path of your choosing and
# pass that info in as an environmental variable.
CMD bundle exec ./bin/crowd server start -e $RAILS_ENV -p $CLOUD_CROWD_SERVER_PORT -c $CLOUD_CROWD_CONFIG

# Goal of this is to be able to sayyyyyyyy
# docker run -e RAILS_ENV=development -v path/to/config/directory:/cloud_crowd:ro cloud_crowd_server
# docker run -it -p 8080:8080 --env-file=$(pwd)/config/cloud_crowd/docker/env.list --network=documentcloud_default -v $(pwd)/config/cloud_crowd/docker:/cloud_crowd:ro documentcloud_cloud_crowd_server /bin/bash