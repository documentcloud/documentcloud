# Ubuntu 14.04
FROM ubuntu:14.04
MAINTAINER Stefan Wehrmeyer, stefan.wehrmeyer@correctiv.org

RUN apt-get update && apt-get -y -f install build-essential checkinstall curl git-core graphicsmagick irb libbz2-dev libcurl4-openssl-dev libexpat-dev libitext-java libjpeg62-dev libleptonica-dev libpcre3-dev libpng12-dev libpq-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxslt1-dev libyaml-dev libzip-dev mercurial openjdk-6-jdk libreoffice libreoffice-java-common pdftk postfix postgresql postgresql-client postgresql-contrib python-software-properties rdoc ri scons sqlite3 tesseract-ocr-dev tesseract-ocr-eng wget xfsprogs xpdf zlib1g-dev

RUN apt-get install software-properties-common -y && apt-get update && add-apt-repository ppa:brightbox/ruby-ng && apt-get update && apt-get install ruby2.1 ruby2.1-dev -y

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN gem install bundler && bundle install

ENV RAILS_ENV development

RUN service postgresql start && \
 su postgres sh -c "createuser -d -r -s documentcloud" && \
 -u postgres psql -c "ALTER USER documentcloud WITH PASSWORD 'documentcloud';" && \
 su postgres sh -c "createdb -O documentcloud dcloud_development" && \
 su postgres sh -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE dcloud_development to documentcloud;\"" && \
 rake $RAILS_ENV db:migrate

RUN apt-get install nginx

ADD . /home/root/documentcloud
WORKDIR /home/root/documentcloud

EXPOSE 8080

CMD service postgresql start && rake development crowd:server:start crowd:node:start
