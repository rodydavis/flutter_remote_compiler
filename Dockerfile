# Use Google's official Dart image.
# https://hub.docker.com/r/google/dart-runtime/
# FROM google/dart-runtime
FROM cirrusci/flutter:latest-web

USER root

# Service must listen to $PORT environment variable.
# This default value facilitates local development.
ENV PORT 8080
ENV WEB_PORT 3000

EXPOSE $PORT $WEB_PORT 8181 5858 8080 3000

RUN flutter --version

# The target variable
ENV TARGET "World + Dog"

# WORKDIR
RUN mkdir /projects
WORKDIR /projects

COPY . ./

RUN apt-get update
RUN apt-get install -y curl wget gnupg less lsof net-tools git apt-utils -y


# DART
RUN apt-get install apt-transport-https
RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN apt-get update
RUN apt-get install dart -y
ENV PATH="${PATH}:/usr/lib/dart/bin/"
ENV PATH="${PATH}:/root/.pub-cache/bin"

# RUN pub get --offline
RUN pub get

CMD ["dart", "bin/server.dart"]
# RUN dart bin/server.dart