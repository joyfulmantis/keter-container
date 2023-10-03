FROM haskell:9.6.2 as build
RUN git clone https://github.com/snoyberg/keter.git
WORKDIR keter
RUN git checkout faedc34cce27057a47b05ee33ae4d7ddd3727b95
Run cabal update
RUN cabal build
RUN mkdir -p dist
RUN strip `cabal exec -- which keter`
RUN cp `cabal exec -- which keter` ./dist
RUN cp ./packaging/etc/keter-config.yaml ./dist
FROM debian:buster
RUN mkdir -p /var/www/keter/bin && mkdir -p /var/www/keter/etc && mkdir -p /var/www/keter/incoming
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libgmp-dev \
    postgresql-client \
    sudo
COPY --from=build /keter/dist/keter /var/www/keter/bin
COPY --from=build /keter/dist/keter-config.yaml /var/www/keter/etc
EXPOSE 80
VOLUME /var/www/keter/incoming
CMD /var/www/keter/bin/keter /var/www/keter/etc/keter-config.yaml
