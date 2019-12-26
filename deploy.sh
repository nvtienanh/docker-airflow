#!/bin/bash
set -e

if [ $# -eq 0 ]
    then
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
    else
        BRANCH=$1
fi

if [ $BRANCH == "master" ]
then
    AIRFLOW_VERSION="1.10.6"
    IMAGE_TAG="latest"
else
    AIRFLOW_VERSION="$(echo $BRANCH | cut -d'-' -f1)"
    IMAGE_TAG=$BRANCH
fi

echo $BRANCH

deploy() {
    IMAGE_TAG=$1
    AIRFLOW_VERSION=$2
    IMAGE=nvtienanh/airflow:$IMAGE_TAG
    docker build \
    -t $IMAGE \
    --build-arg IMAGE_TAG=$IMAGE_TAG \
    --build-arg AIRFLOW_VERSION=$AIRFLOW_VERSION .
    cd -
    docker push $IMAGE
}


deploy $IMAGE_TAG $AIRFLOW_VERSION
