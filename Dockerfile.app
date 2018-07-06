FROM ruby:2.3.5

LABEL authors="Ted Han,Dylan Freedman"




# Install OS dependencies
RUN apt-get update
ADD ./config/server/scripts /setup
RUN /bin/bash -c /setup/setup_minimal_dependencies.sh


# Install Ruby dependencies
ADD Gemfile /documentcloud/Gemfile
ADD Gemfile.lock /documentcloud/Gemfile.lock
ENV ARE_WE_DOCUMENTCLOUD yes

WORKDIR /documentcloud

# see https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-04-github-credentials-in-bundler.md
ARG github_user
ARG github_token
RUN bundle config github.com $github_user:$github_token && (bundle install --without pdf_processing) && bundle config --delete github.com

# If runtime config is not copied in, default to running in
# Development mode (see config/cloud_crowd/* ).
ENV RAILS_ENV               development
ENV CLOUD_CROWD_SERVER_HOST cloud_crowd_server
ENV CLOUD_CROWD_SERVER_PORT 8080

ENV DB_USERNAME documentcloud
ENV DB_PASSWORD documentcloud
ENV DB_HOST     db

ENV PASSENGER_POOL_SIZE 6

EXPOSE 8765

ADD . /documentcloud

# Install Node/Yarn
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg
RUN echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update && apt-get install -qq -y --no-install-recommends nodejs yarn
# Install packages with yarn
RUN yarn
# Copy node_modules into javascript vendor dirs
RUN rm -rf public/javascripts/vendor
RUN ln -s /documentcloud/node_modules/ /documentcloud/public/javascripts/vendor
# RUN cp -r node_modules public/javascripts/vendor

# To run in other environments, use Docker Volumes to
# Copy configuration into path of your choosing and
# pass that info in as an environmental variable.
CMD bundle exec passenger start --port 8765 --environment $RAILS_ENV --max-pool-size $PASSENGER_POOL_SIZE

# Goal of this is to be able to sayyyyyyyy
# docker run -e RAILS_ENV=development -v path/to/config/directory:/cloud_crowd:ro documentcloud_app
# docker run -it -p 7654:8765 --network=documentcloud_default documentcloud_app /bin/bash