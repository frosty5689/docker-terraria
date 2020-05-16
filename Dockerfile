FROM alpine:3.11 as base

RUN apk add --no-cache --update \
    ca-certificates \
    tzdata && \
    update-ca-certificates

ARG TERRARIA_VERSION=1401

RUN apk add --no-cache --update --virtual build-dependencies wget unzip && \
    wget -O /tmp/terraria-$TERRARIA_VERSION.zip http://terraria.org/server/terraria-server-$TERRARIA_VERSION.zip && \
    ls -l /tmp && \
    mkdir -p /opt && \
    unzip /tmp/terraria-$TERRARIA_VERSION.zip -d /opt && \
    mv /opt/$TERRARIA_VERSION/Linux /opt/terraria && \
    mv /opt/$TERRARIA_VERSION/Windows/serverconfig.txt /opt/terraria/serverconfig-default.txt && \
    cd /opt/terraria && \
    rm -rf /opt/$TERRARIA_VERSION && \
    rm -rf /tmp/terraria-$TERRARIA_VERSION.zip && \
    apk del build-dependencies

ADD run/* /opt/terraria/

FROM mono:6.8

LABEL maintainer frosty5689 <frosty5689@gmail.com>

RUN apt-get update \
    && apt-get install -y screen \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=base /opt/terraria /opt/terraria

VOLUME /config

WORKDIR /opt/terraria

CMD ["/opt/terraria/start.sh"]
