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
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    libzip-dev \
    mercurial \
    openjdk-6-jdk \
    libreoffice \
    libreoffice-java-common \
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

ADD . /src/documentcloud
ADD ./contrib/docker/my_init.d /etc/my_init.d
ADD ./contrib/docker/svc /etc/service

# Set default RAILS_ENV. This can easily be overridden on the commandline to
# `docker run`.
ENV RAILS_ENV production

EXPOSE 80

CMD ['/sbin/my_init']
