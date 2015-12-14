# 

FROM registry.opensource.zalan.do/stups/openjdk:8u66-b17-1-8

MAINTAINER Paul Ebermann <Paul.Ebermann@zalando.de>

RUN apt-get install apt-transport-https

ENV CEYLON_VERSION 1.2.0

COPY docker-stuff/ceylon-debian-repo.gpg.key /root/ceylon-debian-repo.gpg.key

RUN apt-key add /root/ceylon-debian-repo.gpg.key && \
    rm /root/ceylon-debian-repo.gpg.key && \
    echo "deb https://downloads.ceylon-lang.org/apt/ unstable main" > /etc/apt/sources.list.d/swagger.list  && \
    apt-get update && \
    apt-get install ceylon-$CEYLON_VERSION && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

COPY modules ceylon-modules
COPY cache   ceylon-cache
COPY scm-source.json /scm-source.json

STOPSIGNAL SIGINT

EXPOSE 8080
CMD ceylon run --rep=/ceylon-modules --cache=/ceylon-cache org.zalando.ceylon_stups.helloWorld

