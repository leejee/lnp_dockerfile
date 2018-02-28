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

RUN yum install -y wget && \
    cp -rf /etc/yum.repos.d /etc/yum.repos.d_backup && \
    wget -qO /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo && \
    wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo && \
    yum clean all && \
    yum makecache && \
    yum install -y gcc gcc-c++ make && \
    yum install -y pcre-devel zlib-devel openssl-devel unzip && \
    yum install -y gd gd-devel libxml2 libxml2-devel libmcrypt libmcrypt-devel re2c libmemcached && \
    yum install -y python-setuptools && \
    easy_install supervisor && \
    yum clean headers && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    useradd work

COPY supervisord.conf /etc/supervisord.conf

USER work
WORKDIR /home/work
RUN mkdir -p lnp logs/install_logs logs/nginx logs/php logs/supervisor webroot
VOLUME /home/work/logs
RUN cd /home/work/lnp && \
    wget ${NGINX_SOURCE} -O ${NGINX_FILE}.tar.gz  && \
    wget ${PHP_SOURCE} -O ${PHP_FILE}.tar.gz && \
    wget ${NGINX_HTTP_CONCAT} -O nginx_http_concat.zip && \
    tar xvzf ${PHP_FILE}.tar.gz && \
    unzip nginx_http_concat.zip -d nginx_http_concat && \
    tar xvzf ${NGINX_FILE}.tar.gz && \
    cd /home/work/lnp/${PHP_FILE} && \
    ./configure --prefix=/home/work/lnp/php --with-config-file-path=/home/work/lnp/php/etc --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --enable-bcmath --enable-shmop --enable-sysvsem --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-pear --disable-rpath --with-mysql --with-mysqli --with-pdo-mysql --enable-opcache > /dev/null 2>/home/work/logs/install_logs/configure_php.err &&\
    make > /dev/null 2>/home/work/logs/install_logs/make_php.err && \
    make install > /dev/null 2>/home/work/logs/install_logs/make_install_php.err && \
    cd /home/work/lnp/${NGINX_FILE} && \
    ./configure --prefix=/home/work/lnp/nginx --conf-path=/home/work/lnp/nginx/conf/nginx.conf --with-pcre --with-http_ssl_module --add-module=/home/work/lnp/nginx_http_concat/nginx-http-concat-master > /dev/null 2>/home/work/logs/install_logs/configure_nginx.err && \
    make > /dev/null 2>/home/work/logs/install_logs/make_nginx.err && \
    make install > /dev/null 2>/home/work/logs/install_logs/make_install_nginx.err && \
    ln -s /home/work/vhost /home/work/lnp/nginx/conf/vhost && \
    cd /home/work/lnp && \
    rm -rf /home/work/lnp/${NGINX_FILE} && \
    rm -f /home/work/lnp/${NGINX_FILE}.tar.gz && \
    rm -rf /home/work/lnp/nginx_http_concat && \
    rm -f /home/work/lnp/nginx_http_concat.zip && \
    rm -rf /home/work/lnp/${PHP_FILE} && \
    rm -f /home/work/lnp/${PHP_FILE}.tar.gz

COPY nginx.conf /home/work/lnp/nginx/conf/
COPY php-fpm.conf /home/work/lnp/php/etc/
COPY php.ini /home/work/lnp/php/etc/
	
#暴露端口号
EXPOSE 8080

ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
