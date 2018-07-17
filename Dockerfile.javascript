FROM node:9

LABEL authors="Dylan Freedman"

# Install packages with NPM
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /javascript && cp -a /tmp/node_modules/* /javascript/

# Map the javascript volume
VOLUME /javascript