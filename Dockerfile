FROM node
MAINTAINER Jason Ozias <jason.g.ozias@gmail.com>

# Expose 3000 for linking
EXPOSE 3000

# Create app directory
RUN mkdir -p /usr/src/ellmak
WORKDIR /usr/src/ellmak

# Install app dependencies
COPY api/package.json /usr/src/ellmak/package.json
RUN npm i && npm prune && npm dedupe

# Source not bundled here.
# Hosted from the api local directory.

CMD [ "npm", "start" ]
