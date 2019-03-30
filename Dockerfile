FROM        buildpack-deps:stretch
MAINTAINER  Jonathan Schmeling
ARG         EMAIL_ADDRESS
ARG         EMAIL_PASSWORD
ENV         LANG                    C.UTF-8
ENV         NGINX_VERSION           1.15.3-1~stretch
ENV         NJS_VERSION             1.15.3.0.2.3-1~stretch
