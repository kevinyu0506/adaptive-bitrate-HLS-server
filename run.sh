#!/bin/bash

docker build -t nginx-rtmp .

docker run --rm -p 8080:80 -p 1935:1935 -d nginx-rtmp
