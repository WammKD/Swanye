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

# root is the person who gets all mail for userids < 1000
RUN echo "root=jaft.r@outlook.com" >> /etc/ssmtp/ssmtp.conf

# Here is the gmail configuration (or change it to your private smtp server)
RUN echo "mailhub=smtp.gmail.com:587" >> /etc/ssmtp/ssmtp.conf
RUN echo "AuthUser=$EMAIL_ADDRESS"    >> /etc/ssmtp/ssmtp.conf
RUN echo "AuthPass=$EMAIL_PASSWORD"   >> /etc/ssmtp/ssmtp.conf

RUN echo "UseTLS=YES"      >> /etc/ssmtp/ssmtp.conf
RUN echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf

COPY ./guile.m4 /tmp

RUN set -ex \
#        && wget -c ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.32.tar.gz \
#        && tar xvzf libgpg-error-1.32.tar.gz \
#        && rm -f libgpg-error-1.32.tar.gz \
#        && cd libgpg-error-1.32 && ./configure && make \
#        && make check && make install && ldconfig \
#        \
#        && wget -c ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.8.3.tar.gz \
#        && tar xvzf libgcrypt-1.8.3.tar.gz \
#        && rm -f libgcrypt-1.8.3.tar.gz \
#        && cd libgcrypt-1.8.3 && ./configure && make \
#        && make check && make install && ldconfig \
#        \
        && wget -c ftp://ftp.gnu.org/gnu/guile/guile-$GUILE_VERSION.tar.gz \
        && tar xvzf guile-$GUILE_VERSION.tar.gz \
        && rm -f guile-$GUILE_VERSION.tar.gz \
        && cd guile-$GUILE_VERSION && ./configure && make \
        && make install && ldconfig \
        && cd .. && rm -rf guile-$GUILE_VERSION \
	\
        && wget -c https://github.com/weinholt/industria/archive/v$INDUSTRIA_VERSION.tar.gz \
        && tar xvzf v$INDUSTRIA_VERSION.tar.gz \
        && rm -f v$INDUSTRIA_VERSION.tar.gz \
        && mkdir /usr/local/share/guile/2.2/industria \
        && mkdir /usr/local/share/guile/2.2/industria/crypto \
        && cp industria-$INDUSTRIA_VERSION/crypto/blowfish.sls /usr/local/share/guile/2.2/industria/crypto/blowfish.scm \
        && rm -rf industria-$INDUSTRIA_VERSION \
        \
        && wget -c https://github.com/opencog/guile-dbi/archive/guile-dbi-$GUILE_DBI_VERSION.tar.gz \
        && tar xvzf guile-dbi-$GUILE_DBI_VERSION.tar.gz \
        && rm -f guile-dbi-$GUILE_DBI_VERSION.tar.gz \
        && cd guile-dbi-guile-dbi-$GUILE_DBI_VERSION/guile-dbi && ./autogen.sh && make \
        && make install && ldconfig \
        && cd ../guile-dbd-mysql && ./autogen.sh && make \
        && make install && ldconfig \
        && cd ../.. && rm -rf guile-dbi-guile-dbi-$GUILE_DBI_VERSION \
        \
#        && wget -c http://ftp.gnu.org/gnu/artanis/artanis-$ARTANIS_VERSION.tar.bz2 \
#        && tar xvjf artanis-$ARTANIS_VERSION.tar.bz2 \
#        && rm -f artanis-$ARTANIS_VERSION.tar.bz2 \
#        && cd artanis-$ARTANIS_VERSION && ./configure && make \
#        && make install && ldconfig \
        && wget -c https://gitlab.com/NalaGinrut/artanis/-/archive/master/artanis-master.tar.gz \
        && tar xvzf artanis-master.tar.gz \
        && rm -f artanis-master.tar.gz \
        && cd artanis-master && ./autogen.sh && ./configure && make \
        && make install && ldconfig \
        && cd .. && rm -rf artanis-master \
