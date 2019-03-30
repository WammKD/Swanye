FROM        buildpack-deps:stretch
MAINTAINER  Jonathan Schmeling
ARG         EMAIL_ADDRESS
ARG         EMAIL_PASSWORD
ENV         LANG                    C.UTF-8
ENV         NGINX_VERSION           1.15.3-1~stretch
ENV         NJS_VERSION             1.15.3.0.2.3-1~stretch
ENV         GUILE_VERSION           2.2.3
ENV         INDUSTRIA_VERSION       2.0.0
ENV         ARTANIS_VERSION         0.3.1
ENV         GUILE_DBI_VERSION       2.1.7
ENV         GUILE_DBD_MYSQL_VERSION 2.1.6
RUN         echo "deb http://mirrors.ustc.edu.cn/debian jessie main contrib non-free"     >> /etc/apt/sources.list && \
            echo "deb-src http://mirrors.ustc.edu.cn/debian jessie main contrib non-free" >> /etc/apt/sources.list
RUN         apt-get update && apt-get build-dep  -y --no-install-recommends guile-2.0 \
                           && apt-get install -q -y --no-install-recommends openssl ssmtp mailutils \
                           && rm -rf /var/lib/apt/lists/*
