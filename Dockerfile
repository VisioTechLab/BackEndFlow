FROM php:8.2-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        intl \
        opcache \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY docker/php/custom.ini /usr/local/etc/php/conf.d/99-leyisa.ini

EXPOSE 8000

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
