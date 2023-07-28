#!/bin/bash

rm -rf ./build
mkdir build


echo "Copying files to build directory... Done"
rsync -a \
--exclude-from=.build-exclude.txt \
--exclude-from=.gitignore \
./ ./build


# copy env.production to .env
cp ./.env.production ./build/.env

# clean storage & bootstrap/cache
find ./build/storage -type f -delete
find ./build/bootstrap/cache -type f -delete


cd ./build || exit

echo "Copying files to build directory... Done"

# Install composer dependencies
echo "Installing composer dependencies..."
composer install

# Install npm dependencies
echo "Installing npm dependencies..."
pnpm install

# Build the frontend
echo "Building the frontend..."

pnpm run build

# Create production bundles
echo "Creating production bundles..."

rm -rf ./vendor
rm -rf ./node_modules

composer install --no-dev --optimize-autoloader
pnpm install --production

php artisan cache:clear
php artisan optimize:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan event:clear

rm -rf ./bootstrap/cache/*

php artisan key:generate

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Remove stuff needed for build
echo "Removing stuff needed for build..."
rm -rf ./postcss.config.js
rm -rf ./tailwind.config.js
rm -rf ./vite.config.js

rm -rf ./database
rm -rf ./tests

# quick little hack to make it work on server
sed -i 's/\/home\/lukas-jirak\/Coding\/book-it\/build/\/var\/www\/localhost\/web/g' ./bootstrap/cache/config.php

# Run on server !!!!!
#ln -s /var/www/localhost/web/storage/app/public/ /var/www/localhost/web/public/storage
#chmod -R 775 storage
#chmod -R 775 bootstrap/cache