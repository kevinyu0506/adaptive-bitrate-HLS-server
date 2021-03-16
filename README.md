# Adaptive bitrate HTTP Live Streaming (HLS) server

This is a containerize streaming server with Nginx as a reverse proxy.

![nginx-rtmp](https://github.com/kevinyu0506/NM7623/blob/master/img/nginx-rtmp.png?raw=true)

## Getting Started

These instruction will get you a copy of the project up and running on your local machine for development and testing purpose.

### Requirements

* Docker

### Quick Start

Build an image called `nginx-rtmp`, and check if that succeed.
```
$ docker build -t nginx-rtmp .
```

Create a running container base on the previous image we've just created.
```
$ docker run --rm --name nginx-rtmp -v $(pwd)/mount:/mount -p 8080:80 -p 1935:1935 nginx-rtmp
```

Or simpy just run the short-cut shell script below
```
$ cd script
$ sh run.sh
```

Now open up your browser (http://localhost:8080) and you should see the Nginx's welcoming page.

### Test

We use ffmpeg to test our server. (This should take a while when building the first time)
```
$ cd script
$ sh test.sh
```
Now we can head to (http://localhost:8080/stream.html) and see the testing video being streamed.

