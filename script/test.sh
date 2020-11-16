#!/bin/bash

sh run.sh

cd ../test

docker build -t alpine-ffmpeg .

docker run --rm --net=container:nginx-rtmp -it alpine-ffmpeg ffmpeg -re -i ./bunny.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -f flv rtmp://172.17.0.2:1935/stream/bunny

cd ../script

sh stop.sh
