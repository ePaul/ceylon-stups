#! /bin/bash

MODULE_VERSION=$( egrep 'module .* {' source/org/zalando/ceylon_stups/helloWorld/module.ceylon | sed -r 's/.*"([^"]+)" \{/\1/' )

ceylon compile --cacherep=./cache org.zalando.ceylon_stups.helloWorld
scm-source

sudo docker build -t pierone.stups.zalan.do/hackweek/ceylon-stups-helloworld:$MODULE_VERSION .
sudo docker push pierone.stups.zalan.do/hackweek/ceylon-stups-helloworld:$MODULE_VERSION
