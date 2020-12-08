# NM7623 Video Compression Technique, standards and implementation

[NM7623 Video Compression Technique, standards and implementation](https://nol.ntu.edu.tw/nol/coursesearch/print_table.php?course_id=944%20U0020&class=&dpt_code=9440&ser_no=79602&semester=109-1) final project.

## About the project

This is a containerize RTMP server with Nginx as a reverse proxy. 

## Getting Started

These instruction will get you a copy of the project up and running on your local machine for development and testing purpose.

### Requirements

* Install docker

### Quick Start

Build an image called `nginx-rtmp`, and check if that succeed.
```
$ docker build -t nginx-rtmp .
```

Create a running container base on the previous image we've just created.
```
$ docker run --rm --name nginx-rtmp -v $(pwd)/mount:/mount -p 8080:80 -p 1935:1935 -d nginx-rtmp
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

