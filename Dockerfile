#This dockerfile use the centos
#
#Author:lee
#Command format:
FROM centos:6

MAINTAINER lee<liji09@126.com>

# 定义环境变量
ENV NGINX_HTTP_CONCAT https://github.com/alibaba/nginx-http-concat/archive/master.zip

ENV NGINX_VERSION 1.12.2
ENV NGINX_FILE nginx-${NGINX_VERSION}
ENV NGINX_SOURCE http://nginx.org/download/${NGINX_FILE}.tar.gz

ENV PHP_VERSION 5.6.33
ENV PHP_FILE php-${PHP_VERSION}
ENV PHP_SOURCE http://php.net/get/${PHP_FILE}.tar.gz/from/this/mirror

ENV WORKHOME /home/work 

RUN yum clean all
RUN yum makecache
RUN yum install -y wget

RUN cp -rf /etc/yum.repos.d /etc/yum.repos.d_backup
RUN wget -qO /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
RUN wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo

RUN yum clean all
RUN yum makecache
RUN yum install -y gcc gcc-c++ make
RUN yum install -y pcre-devel zlib-devel openssl-devel
RUN yum install -y unzip
RUN yum install -y gd gd-devel libxml2 libxml2-devel libmcrypt libmcrypt-devel re2c libmemcached


RUN useradd work
USER work
WORKDIR /home/work/
RUN mkdir -p lnp logs/install_logs logs/nginx logs/php logs/supervisor webroot
VOLUME /home/work/logs

WORKDIR /home/work/lnp
RUN wget ${PHP_SOURCE} -O ${PHP_FILE}.tar.gz && \
	tar xvzf ${PHP_FILE}.tar.gz 
WORKDIR /home/work/lnp/${PHP_FILE} 

RUN ./configure --prefix=/home/work/lnp/php --with-config-file-path=/home/work/lnp/php/etc --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --enable-bcmath --enable-shmop --enable-sysvsem --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-pear --disable-rpath --with-mysql --with-mysqli --with-pdo-mysql --enable-opcache > /home/work/logs/install_logs/configure_php.log 2>/home/work/logs/install_logs/configure_php.err
RUN make > /home/work/logs/install_logs/make_php.log 2>/home/work/logs/install_logs/make_php.err
RUN make install > /home/work/logs/install_logs/make_install_php.log 2>/home/work/logs/install_logs/make_install_php.err 

WORKDIR /home/work/lnp/

RUN wget ${NGINX_HTTP_CONCAT} -O nginx_http_concat.zip
RUN unzip nginx_http_concat.zip -d nginx_http_concat

RUN wget ${NGINX_SOURCE} -O ${NGINX_FILE}.tar.gz  && \
tar xvzf ${NGINX_FILE}.tar.gz 
WORKDIR /home/work/lnp/${NGINX_FILE} 

RUN ./configure --prefix=/home/work/lnp/nginx --conf-path=/home/work/lnp/nginx/conf/nginx.conf --with-pcre --with-http_ssl_module --add-module=/home/work/lnp/nginx_http_concat/nginx-http-concat-master > /home/work/logs/install_logs/configure_nginx.log 2>/home/work/logs/install_logs/configure_nginx.err
RUN make > /home/work/logs/install_logs/make_nginx.log 2>/home/work/logs/install_logs/make_nginx.err
RUN make install > /home/work/logs/install_logs/make_install_nginx.log 2>/home/work/logs/install_logs/make_install_nginx.err 

COPY nginx.conf /home/work/lnp/nginx/conf/
COPY php-fpm.conf /home/work/lnp/php/etc/
COPY php.ini /home/work/lnp/php/etc/
RUN ln -s /home/work/vhost /home/work/lnp/nginx/conf/vhost

USER root
RUN yum install -y python-setuptools
RUN easy_install supervisor
COPY supervisord.conf /etc/supervisord.conf
ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
RUN yum clean all
	
#暴露端口号
EXPOSE 8080
USER work
WORKDIR /home/work

