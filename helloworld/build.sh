#! /bin/bash

set -o errexit

CEYLON_MODULE_NAME=org.zalando.ceylon_stups.helloWorld
MODULE_VERSION=$( egrep 'module .* {' source/org/zalando/ceylon_stups/helloWorld/module.ceylon | sed -r 's/.*"([^"]+)" \{/\1/' )
DOCKER_ARTIFACT_NAME=pierone.stups.zalan.do/hackweek/ceylon-stups-helloworld

rm -r ./cache
rm -r ./modules
echo "Ceylon building ..."
ceylon compile --cacherep=./cache $CEYLON_MODULE_NAME
echo "... Ceylon build done."
scm-source

sudo docker build -t $DOCKER_ARTIFACT_NAME:$MODULE_VERSION .
echo ""
echo "built $DOCKER_ARTIFACT_NAME:$MODULE_VERSION"

if [[ "$1" = "-push" ]]
then
  echo "pushing to registry ..." 
  sudo docker push $DOCKER_ARTIFACT_NAME:$MODULE_VERSION
else
  echo "omitted pushing."
fi 
