#!/bin/sh
#
# Runs a bootnode with ethereum official "alltools" image.
#
docker stop ethereum-bootnode
docker rm ethereum-bootnode
NODE_NAME=$1
NODE_NAME=${NODE_NAME:-"boot1"}
CONTAINER_NAME="ethereum-$NODE_NAME"
IMGNAME="ethereum/client-go:alltools-v1.7.3"
DATA_ROOT=${DATA_ROOT:-$(pwd)}
# generate bootnode key if needed
mkdir -p $DATA_ROOT/.bootnode
if [ ! -f $DATA_ROOT/.bootnode/boot.key ]; then
    echo "$DATA_ROOT/.bootnode/boot.key not found, generating..."
    docker run --rm \
        -v $DATA_ROOT/.bootnode:/opt/bootnode \
        $IMGNAME bootnode --genkey /opt/bootnode/boot.key
    echo "...done!"
fi
# creates ethereum network
#[ ! "$(docker network ls | grep ethereum)" ] && docker network create ethereum
[[ -z $BOOTNODE_SERVICE ]] && BOOTNODE_SERVICE="127.0.0.1"
docker run -d --name $CONTAINER_NAME \
    -P \
    -p 30301:30301 \
    -p 30301:30301/udp \
    -v $DATA_ROOT/.bootnode:/opt/bootnode \
    $IMGNAME bootnode --nodekey /opt/bootnode/boot.key --verbosity=3 "$@"
# --addr "$BOOTNODE_SERVICE:30301" "$@"


