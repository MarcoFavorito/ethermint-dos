#!/usr/bin/env bash

WORKING_DIR=./bench/ethermint_dockerized
TSUNG_CONFIG_FILE=$WORKING_DIR/ethermint_dockerized.xml

rm -R $WORKING_DIR/normal $WORKING_DIR/evil $WORKING_DIR/graphs
mkdir $WORKING_DIR/normal $WORKING_DIR/evil $WORKING_DIR/graphs
docker rm -f $(docker ps -a --filter name="local_testnet" -q)
docker build -t marcofavorito/ethermint-dos -f ./docker/Dockerfile .

echo "***********************************************"
echo "Test normal network (where all nodes are correct)"
./scripts/tsung_test.sh $TSUNG_CONFIG_FILE  $WORKING_DIR/normal    "python3 ethermint-dos.py 4 0 --verbosity 1" "ETHERMINT"

docker rm -f $(docker ps -a --filter name="local_testnet" -q)

echo "***********************************************"
echo "Test evil network (with one byzantine node)"
./scripts/tsung_test.sh $TSUNG_CONFIG_FILE  $WORKING_DIR/evil      "python3 ethermint-dos.py 4 1 --verbosity 1" "ETHERMINT"

docker rm -f $(docker ps -a --filter name="local_testnet" -q)


LAST_LOG_DIR_NORM=$(ls $WORKING_DIR/normal/log/| grep -o -E "[0-9]{8}-[0-9]{4}" | tail -1)
LAST_LOG_DIR_EVIL=$(ls $WORKING_DIR/evil/log/| grep -o -E "[0-9]{8}-[0-9]{4}" | tail -1)

echo "***********************************************"

tsplot "Normal" $WORKING_DIR/normal/log/$LAST_LOG_DIR_NORM/tsung.log "Evil" $WORKING_DIR/evil/log/$LAST_LOG_DIR_EVIL/tsung.log -d $WORKING_DIR/graphs
cd $WORKING_DIR/graphs/
find . ! -name '*_tn.png'  | xargs firefox
