FROM nginx:1.26-alpine

COPY config/conf.d/default.conf /etc/nginx/conf.d/default.conf

COPY config/nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/html
