FROM        buildpack-deps:buster
MAINTAINER  Jonathan Schmeling
ARG         EMAIL_ADDRESS
ARG         EMAIL_PASSWORD
ENV         LANG                    C.UTF-8
ENV         ARTANIS_VERSION         0.3.1
ENV         NGINX_VERSION           1.17.4-1~buster
ENV         NJS_VERSION             1.17.4.0.3.5-1~buster
ENV         GUILE_VERSION           2.2.6
ENV         INDUSTRIA_VERSION       2.1.0
ENV         GUILE_DBI_VERSION       2.1.7
ENV         GUILE_DBD_MYSQL_VERSION 2.1.6
RUN         echo "deb http://mirrors.ustc.edu.cn/debian stretch main contrib non-free"     >> /etc/apt/sources.list && \
            echo "deb-src http://mirrors.ustc.edu.cn/debian stretch main contrib non-free" >> /etc/apt/sources.list
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
        && wget -c https://ftp.gnu.org/gnu/nettle/nettle-3.4.1.tar.gz \
        && tar xvzf nettle-3.4.1.tar.gz \
	&& rm -f nettle-3.4.1.tar.gz \
        && cd nettle-3.4.1 && ./configure && make \
        && make install && ldconfig \
        && cd .. && rm -rf nettle-3.4.1 \
	\
        && wget -c https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.13.tar.gz \
        && tar xvzf libtasn1-4.13.tar.gz \
        && rm -f libtasn1-4.13.tar.gz \
        && cd libtasn1-4.13 && ./configure && make \
        && make install && ldconfig \
        && cd .. && rm -rf libtasn1-4.13 \
	\
        && wget -c https://github.com/p11-glue/p11-kit/releases/download/0.23.15/p11-kit-0.23.15.tar.gz \
        && tar xvzf p11-kit-0.23.15.tar.gz \
        && rm -f p11-kit-0.23.15.tar.gz \
        && cd p11-kit-0.23.15 && ./configure && make \
        && make install && ldconfig \
        && cd .. && rm -rf p11-kit-0.23.15 \
	\
        && wget -c https://www.gnupg.org/ftp/gcrypt/gnutls/v3.6/gnutls-3.6.7.tar.xz \
        && tar xJf gnutls-3.6.7.tar.xz \
        && rm -f gnutls-3.6.7.tar.xz \
        && cd gnutls-3.6.7 && ./configure --enable-guile GUILE="/usr/local/bin/guile" && make \
        && make install && ldconfig \
        && cd .. && rm -rf gnutls-3.6.7 \
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
        \
#        && wget -c https://notabug.org/cwebber/guile-gcrypt/archive/v0.1.0.tar.gz \
#        && tar xvzf v0.1.0.tar.gz \
#        && rm -f v0.1.0.tar.gz \
#        && cd guile-gcrypt \
#        && mv /tmp/guile.m4 ./m4 \
#        && ./bootstrap.sh && ./configure && make \
#        && make install && ldconfig \
#        \
#	&& wget -c https://github.com/artyom-poptsov/guile-ssh/archive/v0.11.3.tar.gz \
#	&& tar xvzf v0.11.3.tar.gz \
#	&& rm -r v0.11.3.tar.gz \
#	&& cd guile-ssh-0.11.3 && autoreconf --install && ./configure && make \
#	&& make install && ldconfig \
#	\
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y gnupg1 apt-transport-https ca-certificates \
	&& \
	NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
	found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
		apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
	apt-get remove --purge --auto-remove -y gnupg1 && rm -rf /var/lib/apt/lists/* \
	&& dpkgArch="$(dpkg --print-architecture)" \
	&& nginxPackages=" \
		nginx=${NGINX_VERSION} \
		nginx-module-xslt=${NGINX_VERSION} \
		nginx-module-geoip=${NGINX_VERSION} \
		nginx-module-image-filter=${NGINX_VERSION} \
		nginx-module-njs=${NJS_VERSION} \
	" \
	&& case "$dpkgArch" in \
		amd64|i386) \
# arches officialy built by upstream
			echo "deb https://nginx.org/packages/mainline/debian/ buster nginx" >> /etc/apt/sources.list.d/nginx.list \
			&& apt-get update \
			;; \
		*) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published source packages
			echo "deb-src https://nginx.org/packages/mainline/debian/ buster nginx" >> /etc/apt/sources.list.d/nginx.list \
			\
# new directory for storing sources and .deb files
			&& tempDir="$(mktemp -d)" \
			&& chmod 777 "$tempDir" \
# (777 to ensure APT's "_apt" user can access it too)
			\
# save list of currently-installed packages so build dependencies can be cleanly removed later
			&& savedAptMark="$(apt-mark showmanual)" \
			\
# build .deb files from upstream's source packages (which are verified by apt-get)
			&& apt-get update \
			&& apt-get build-dep -y $nginxPackages \
			&& ( \
				cd "$tempDir" \
				&& DEB_BUILD_OPTIONS="nocheck parallel=$(nproc)" \
					apt-get source --compile $nginxPackages \
			) \
# we don't remove APT lists here because they get re-downloaded and removed later
			\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
# (which is done after we install the built packages so we don't have to redownload any overlapping dependencies)
			&& apt-mark showmanual | xargs apt-mark auto > /dev/null \
			&& { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; } \
			\
# create a temporary local APT repo to install from (so that dependency resolution can be handled by APT, as it should be)
			&& ls -lAFh "$tempDir" \
			&& ( cd "$tempDir" && dpkg-scanpackages . > Packages ) \
			&& grep '^Package: ' "$tempDir/Packages" \
			&& echo "deb [ trusted=yes ] file://$tempDir ./" > /etc/apt/sources.list.d/temp.list \
# work around the following APT issue by using "Acquire::GzipIndexes=false" (overriding "/etc/apt/apt.conf.d/docker-gzip-indexes")
#   Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
#   ...
#   E: Failed to fetch store:/var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages  Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
			&& apt-get -o Acquire::GzipIndexes=false update \
			;; \
	esac \
	\
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						$nginxPackages \
						gettext-base \
	&& apt-get remove --purge --auto-remove -y apt-transport-https ca-certificates && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list \
	\
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
	&& if [ -n "$tempDir" ]; then \
		apt-get purge -y --auto-remove \
		&& rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list; \
	fi

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN sed -i -e 's/        root   \/usr\/share\/nginx\/html;/        proxy_pass http:\/\/127.0.0.1:1234;/g' /etc/nginx/conf.d/default.conf
RUN sed -i -e 's/        index  index.html index.htm;/        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;/g' /etc/nginx/conf.d/default.conf

RUN apt-get update && apt-get install -q -y --no-install-recommends openssl

RUN mkdir /myapp
WORKDIR /myapp
COPY . /myapp
