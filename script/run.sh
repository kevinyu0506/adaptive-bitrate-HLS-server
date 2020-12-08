#!/bin/bash

cd ..

docker build -t nginx-rtmp .

docker run --rm --name nginx-rtmp -v $(pwd)/mount:/mount -p 8080:80 -p 1935:1935 -d nginx-rtmp

