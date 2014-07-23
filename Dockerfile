FROM phusion/baseimage:0.9.12
MAINTAINER Stefan Wehrmeyer, stefan.wehrmeyer@correctiv.org

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get -q -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
    build-essential \
    curl \
    git-core \
    graphicsmagick \
    libbz2-dev \
    libcurl4-openssl-dev \
    libexpat-dev \
    libitext-java \
    libjpeg62-dev \
    libleptonica-dev \
    libpcre3-dev \
    libpng12-dev \
    libpq-dev \
    libreadline-dev \
    libreoffice \
    libreoffice-java-common \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    libzip-dev \
    mercurial \
    nginx-light \
    openjdk-6-jdk \
    pdftk \
    postfix \
    scons \
    sqlite3 \
    tesseract-ocr-dev \
    tesseract-ocr-eng \
    wget \
    xfsprogs \
    xpdf \
    zlib1g-dev

RUN add-apt-repository ppa:brightbox/ruby-ng
RUN apt-get -q -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install ruby2.1 ruby2.1-dev

# Don't bother installing documentation for any gems
RUN echo gem: --no-document >>/etc/gemrc

RUN gem install bundler

# Add Gemfile and Gemfile.lock separately so that only changes to these files
# trigger a cache invalidation and a reinstall of all gems.
ADD Gemfile /src/documentcloud/Gemfile
ADD Gemfile.lock /src/documentcloud/Gemfile.lock
RUN bundle install --gemfile=/src/documentcloud/Gemfile --path=/src/documentcloud/.bundle

# Install DocumentCloud and patches
ADD . /src/documentcloud
ADD ./contrib/docker/patches /src/documentcloud/patches
RUN for f in /src/documentcloud/patches/*; do patch -p1 -d /src/documentcloud/ <$f; done
RUN bundle install --gemfile=/src/documentcloud/Gemfile --path=/src/documentcloud/.bundle
ADD ./contrib/docker/initializers /src/documentcloud/config/initializers

ADD ./contrib/docker/my_init.d /etc/my_init.d
ADD ./contrib/docker/svc /etc/service

# Set default RAILS_ENV. This can easily be overridden on the commandline to
# `docker run`.
ENV RAILS_ENV production

# Configure nginx in order to futz with hostnames and SSL. This is a VERY BAD
# IDEA, unless you are planning on deploying this container behind SSL
# termination, so please ensure you understand the implications of the below
# before using this image.
ADD ./contrib/docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ['/sbin/my_init']

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
