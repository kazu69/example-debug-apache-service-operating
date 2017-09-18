FROM 'php:5.6.31-apache'

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_LOG_DIR /var/log/apache2
ENV PHP_INI_DIR /usr/local/etc/php

RUN apt-get update -y \
    && apt-get install -y strace \
        build-essential \
        gdb \
        psmisc \
        apache2-dev

ADD html /var/www/html
ADD php-ext/example /tmp/extensions/example
RUN cd /tmp/extensions/example \
    && phpize \
    && ./configure \
    && make \
    && php -d extension=modules/example.so example.php \
    && make install

ADD conf/php.ini ${PHP_INI_DIR}/php.ini

# forkするプロセスの設定
COPY conf/prefork.conf ${APACHE_CONFDIR}/conf-enabled/prefork.conf
COPY conf/coredump.conf /etc/apache2/conf-enabled/coredump.conf

# Error cannot create /proc/sys/kernel/core_pattern: Read-only file system
# となるので別途設定する
# RUN echo '/tmp/core.%h.%e.%t' > /proc/sys/kernel/core_pattern

# ログをファイルに出力するように変更
RUN unlink ${APACHE_LOG_DIR}/error.log \
 && unlink ${APACHE_LOG_DIR}/access.log

EXPOSE 80
CMD ["apache2-foreground"]
