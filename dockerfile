FROM nginx

COPY ./index.html /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

