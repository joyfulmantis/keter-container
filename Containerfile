FROM debian:bullseye as build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    g++ gcc \
    libc6-dev \
    libffi-dev \
    libgmp-dev \
    make \
    xz-utils \
    zlib1g-dev \
    git \
    gnupg \
    netbase \
    git \
    libpq-dev \
    curl
RUN curl -sSL https://get.haskellstack.org/ | sh
RUN git clone https://github.com/snoyberg/keter.git
WORKDIR keter
RUN git checkout 088cdf64c4fcf7ac7049b4db503e7fa061ffd9f5
RUN stack --resolver=lts-18 build
RUN mkdir -p dist
RUN strip `stack --resolver=lts-18 exec -- which keter`
RUN cp `stack --resolver=lts-18 exec -- which keter` ./dist
RUN cp ./packaging/etc/keter-config.yaml ./dist
FROM debian:bullseye
RUN mkdir -p /opt/keter/bin && mkdir -p /opt/keter/etc && mkdir -p /opt/keter/incoming
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libgmp-dev \
    postgresql-client
COPY --from=build /keter/dist/keter /opt/keter/bin
COPY --from=build /keter/dist/keter-config.yaml /opt/keter/etc
EXPOSE 80
VOLUME /opt/keter/incoming
CMD /opt/keter/bin/keter /opt/keter/etc/keter-config.yaml
