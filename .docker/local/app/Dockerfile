FROM php:8.4-fpm

ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && apt-get install -y \
    mc unzip rsync npm \
    libzip-dev zlib1g-dev \
    libcurl4-gnutls-dev \
    libicu-dev \
    libpq-dev \
    libxml2-dev \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pgsql --with-pgsql=/usr \
    && docker-php-ext-install -j$(nproc) \
    zip curl intl \
    pdo_pgsql pgsql \
    xml pcntl opcache exif dom

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer --quiet

COPY php.ini /usr/local/etc/php/php.ini

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN groupmod -g ${USER_GID} www-data \
    && usermod -u ${USER_UID} www-data

WORKDIR /var/www/html

USER www-data
