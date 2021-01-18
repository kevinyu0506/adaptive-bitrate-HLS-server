FROM buildpack-deps:stretch AS builder

MAINTAINER Kevin Yu <kevinyu05062006@gmail.com> 
# Versions of Nginx and nginx-rtmp-module to use
ARG NGINX_VERSION=1.18.0
ARG NGINX_RTMP_VERSION=1.2.1
ARG FFMPEG_VERSION=4.3.1


##############################
# Build the NGINX-build image.
FROM alpine:3.11 as nginx-builder
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

# Build dependencies.
RUN apk add --update \
  build-base \
  ca-certificates \
  curl \
  gcc \
  libc-dev \
  libgcc \
  linux-headers \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev

# Get nginx source.
RUN cd /tmp && \
  wget https://nginx.org/download/nginx-1.18.0.tar.gz && \
  tar zxf nginx-1.18.0.tar.gz && \
  rm nginx-1.18.0.tar.gz
#RUN cd /tmp && \
#  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
#  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
#  rm nginx-${NGINX_VERSION}.tar.gz

# Get nginx-rtmp module.
RUN cd /tmp && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v1.2.1.tar.gz && \
  tar zxf v1.2.1.tar.gz && rm v1.2.1.tar.gz
#RUN cd /tmp && \
#  wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
#  tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

# Compile nginx with nginx-rtmp module.
RUN cd /tmp/nginx-1.18.0 && \
  ./configure \
  --prefix=/usr/local/nginx \
  --add-module=/tmp/nginx-rtmp-module-1.2.1 \
  --conf-path=/etc/nginx/nginx.conf \
  --with-threads \
  --with-file-aio \
  --with-http_ssl_module \
  --with-debug \
  --with-cc-opt="-Wimplicit-fallthrough=0" && \
  cd /tmp/nginx-1.18.0 && make && make install

###############################
# Build the FFmpeg-build image.
FROM alpine:3.11 as ffmpeg-builder
ARG FFMPEG_VERSION
ARG PREFIX=/usr/local
ARG MAKEFLAGS="-j4"

# FFmpeg build dependencies.
RUN apk add --update \
  build-base \
  coreutils \
  freetype-dev \
  lame-dev \
  libogg-dev \
  libass \
  libass-dev \
  libvpx-dev \
  libvorbis-dev \
  libwebp-dev \
  libtheora-dev \
  openssl-dev \
  opus-dev \
  pkgconf \
  pkgconfig \
  rtmpdump-dev \
  wget \
  x264-dev \
  x265-dev \
  yasm

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
RUN apk add --update fdk-aac-dev

# Get FFmpeg source.
RUN cd /tmp/ && \
  wget http://ffmpeg.org/releases/ffmpeg-4.3.1.tar.gz && \
  tar zxf ffmpeg-4.3.1.tar.gz && rm ffmpeg-4.3.1.tar.gz

# Compile ffmpeg.
RUN cd /tmp/ffmpeg-4.3.1 && \
  ./configure \
  --prefix=${PREFIX} \
  --enable-version3 \
  --enable-gpl \
  --enable-nonfree \
  --enable-small \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libass \
  --enable-libwebp \
  --enable-postproc \
  --enable-avresample \
  --enable-libfreetype \
  --enable-openssl \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --extra-libs="-lpthread -lm" && \
  make && make install && make distclean

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

##########################
# Build the release image.
FROM alpine:3.11

# Set default ports.
ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV RTMP_PORT 1935

RUN apk add --update \
  ca-certificates \
  gettext \
  openssl \
  pcre \
  lame \
  libogg \
  curl \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev

COPY --from=nginx-builder /usr/local/nginx /usr/local/nginx
COPY --from=nginx-builder /etc/nginx /etc/nginx
COPY --from=ffmpeg-builder /usr/local /usr/local
COPY --from=ffmpeg-builder /usr/lib/libfdk-aac.so.2 /usr/lib/libfdk-aac.so.2

# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
ADD nginx/nginx.conf /etc/nginx/nginx.conf.template
RUN mkdir -p /opt/data && mkdir /www
ADD static /www/static

# Set up config file
#COPY /nginx/nginx.conf /etc/nginx/nginx.conf
COPY /app/www/stream.html /usr/local/nginx/html
COPY /app/www/vod.html /usr/local/nginx/html

#EXPOSE 1935 80
#CMD ["nginx", "-g", "daemon off;"]

CMD envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
  /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
  nginx
