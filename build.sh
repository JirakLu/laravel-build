#!/bin/bash

rm -rf ./build/*
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
npm install

# Build the frontend
echo "Building the frontend..."

rm -rf ./bootstrap/cache/*

npm run build

php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan event:clear

php artisan key:generate

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Create production bundles
echo "Creating production bundles..."

rm -rf ./vendor
rm -rf ./node_modules

composer install --no-dev --optimize-autoloader
npm install --omit=dev

# Remove stuff needed for build
echo "Removing stuff needed for build..."
rm -rf ./postcss.config.js
rm -rf ./tailwind.config.js
rm -rf ./vite.config.js

cp -r . ~/Coding/maturak-docker-koudy/build
