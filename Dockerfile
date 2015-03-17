FROM debian:wheezy

MAINTAINER Roy Inganta Ginting <roy.i.ginting@gdplabs.id>

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_VERSION 1.6.2-1~wheezy
ENV PHP_VERSION 5.6.6-1~dotdeb.1

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 89DF5277 && \
    apt-key adv --keyserver pgp.mit.edu --recv-keys 7BD9BF62 && \
    echo "deb http://packages.dotdeb.org wheezy-php56 all" > \
    /etc/apt/sources.list.d/dotdeb.list && \
    echo "deb http://nginx.org/packages/debian wheezy nginx" > \
    /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get install -y \
    curl \
    supervisor \
    nginx=${NGINX_VERSION} \
    php5=${PHP_VERSION} \
    php5-cli=${PHP_VERSION} \
    php5-fpm=${PHP_VERSION} \
    php5-mysql=${PHP_VERSION} \
    php5-gd=${PHP_VERSION} \
    php5-curl=${PHP_VERSION} \
    php5-mcrypt=${PHP_VERSION} \
    php5-dev=${PHP_VERSION} && \
    pecl install oauth && \
    echo "extension=oauth.so" > /etc/php5/mods-available/oauth.ini && \
    pecl install xdebug && \
    echo "zend_extension=\"`php-config --extension-dir`/xdebug.so\"" > /etc/php5/mods-available/xdebug.ini && \
    php5enmod mcrypt oauth xdebug
    rm -fr /var/lib/apt/list/*

ADD www.conf /etc/php5/fpm/pool.d/www.conf
ADD php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD php.ini /etc/php5/fpm/php.ini
ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /etc/nginx/sites-enabled /var/log/fpm && \
    rm -fr /etc/nginx/conf.d/* && \
    ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

VOLUME ["/var/log/nginx", "/var/log/fpm"]
EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
