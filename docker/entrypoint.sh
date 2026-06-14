#!/bin/sh
set -e

cd /var/www/html

if [ ! -f vendor/autoload.php ]; then
    echo "[leyisa] Installation des dependances Composer..."
    composer install --no-interaction --prefer-dist
fi

echo "[leyisa] Warmup cache Symfony..."
php bin/console cache:clear --no-warmup --no-debug 2>/dev/null || true
php bin/console cache:warmup --no-debug

echo "[leyisa] API disponible sur http://127.0.0.1:8000"
exec php -S 0.0.0.0:8000 -t public public/index.php
