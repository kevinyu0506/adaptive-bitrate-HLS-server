FROM nginx:alpine AS builder

# https://gist.github.com/hermanbanken/96f0ff298c162a522ddbba44cad31081
# https://github.com/arut/nginx-rtmp-module/releases/tag/v1.2.1
# https://www.nginx.com/resources/wiki/modules/

# nginx:alpine contains NGINX_VERSION environment variable, like so:
#ENV NGINX_VERSION 1.15.0

# Our nginx-rtmp-module
ENV NGINX_RTMP_MODULE_VERSION 1.2.1

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
  wget "https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz" -O nginx_rtmp.tar.gz

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
  mkdir /usr/src && \
  tar -zxC /usr/src -f nginx.tar.gz && \
  tar -xzvf "nginx_rtmp.tar.gz" && \
  NGINX_RTMPDIR="$(pwd)/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}" && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  ./configure --with-compat $CONFARGS --add-dynamic-module=$NGINX_RTMPDIR --with-cc-opt="-Wimplicit-fallthrough=0" && \
  make && make install

FROM nginx:alpine
# Extract the dynamic module from the builder image
COPY --from=builder /nginx-rtmp-module-1.2.1/stat.xsl /usr/build/nginx-rtmp-module/stat.xsl
COPY --from=builder /usr/local/nginx/modules/ngx_rtmp_module.so /usr/local/nginx/modules/ngx_rtmp_module.so
#RUN rm /etc/nginx/conf.d/default.conf

COPY ./index.html /usr/share/nginx/html
COPY ./stream.html /mnt
#COPY ./small_bunny_1080p_30fps.mp4 /
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 1935
STOPSIGNAL SIGTERM
#CMD ["nginx", "-g", "daemon off;"]
RUN nginx -t
#RUN nginx -t && nginx -s reload
