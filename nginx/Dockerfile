FROM nginx:1.13

RUN apt-get update && \
    apt-get install -y openssl

COPY generate_ssl_cert.sh /etc/nginx/
RUN /etc/nginx/generate_ssl_cert.sh

COPY default.conf /etc/nginx/conf.d/
