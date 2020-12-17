#!/bin/bash

docker run --rm --net=container:nginx-rtmp -v $(pwd)/../mount:/mount -it linuxserver/ffmpeg -re -i /mount/vod/bunny.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -f flv rtmp://localhost:1935/stream/bunny

