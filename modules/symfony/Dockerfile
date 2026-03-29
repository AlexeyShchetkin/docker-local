ARG PHP_IMAGE=php:8.4-fpm
FROM ${PHP_IMAGE}

ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    mc unzip rsync npm git \
    libzip-dev zlib1g-dev \
    libcurl4-gnutls-dev \
    libicu-dev \
    libpq-dev \
    default-libmysqlclient-dev \
    libxml2-dev \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pgsql --with-pgsql=/usr \
    && docker-php-ext-install -j$(nproc) \
    ctype iconv session \
    zip curl intl \
    pdo_pgsql pgsql \
    pdo_mysql mysqli \
    xml simplexml pcntl opcache exif dom \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Symfony CLI: https://symfony.com/download
COPY --link --from=ghcr.io/symfony-cli/symfony-cli:latest /usr/local/bin/symfony /usr/local/bin/symfony

COPY config/php.ini /usr/local/etc/php/php.ini

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN groupmod -g ${USER_GID} www-data \
    && usermod -u ${USER_UID} www-data \
    && chown -R www-data:www-data /var/www

WORKDIR /var/www/html

USER www-data
