FROM node
MAINTAINER Jason Ozias <jason.g.ozias@gmail.com>

# Expose 3000 for linking
EXPOSE 3000

# Create app directory
RUN mkdir -p /usr/src/yadda
WORKDIR /usr/src/yadda

# Install app dependencies
COPY api/package.json /usr/src/yadda/package.json
RUN npm i && npm prune && npm dedupe

# Source not bundled here.
# Hosted from the api local directory.

CMD [ "npm", "start" ]
