# Configure composer to work in Docker environment

Installation and configuration of composer in docker is a bit tricky.
This tutorial is answer to question "How to configure composer in docker?" and describe all steps of it.

Main idea is that, opposite to docker ideology of separate containers, composer MUST be in same container with PHP.
This required to allow composer to check platform requirements and php extensions.
We need next Dockerfile to do it:

```dockerfile
FROM php:8.1-fpm

USER root

# Creating user and group
RUN getent group www || groupadd -g 1000 www \
    && getent passwd 1000 || useradd -u 1000 -m -s /bin/bash -g www www

# Modify php fpm configuration to use the new user's priviledges.
RUN sed -i "s/user = www-data/user = 'www'/g" /usr/local/etc/php-fpm.d/www.conf \
  && sed -i "s/group = www-data/group = 'www'/g" /usr/local/etc/php-fpm.d/www.conf \
  && echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Installation of services and php extensions configuration
RUN apt-get update -y \
    && apt-get autoremove -y \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    libonig-dev \
    && docker-php-ext-install mbstring pdo pdo_pgsql pgsql \
    && rm -rf /var/lib/apt/lists/*

USER www

COPY --from=composer /usr/bin/composer /usr/bin/composer

CMD php-fpm -y /usr/local/etc/php-fpm.conf -R
```

Composer installed on this step

```dockerfile
COPY --from=composer /usr/bin/composer /usr/bin/composer
```

Next, we need to configure docker-compose file to have separate containers for PHP and for composer:

```yaml
version: '3.1'
  services:
    php:
      build:
        context: .
        dockerfile: Dockerfile
      container_name: playgroundPhp
      restart: unless-stopped
      working_dir: /app/
      volumes:
        - ./app:/app
      networks:
        - backend
  
    composer:
      build:
        context: .
        dockerfile: Dockerfile
      container_name: playgroundComposer
      restart: "no"
      working_dir: /app/
      entrypoint: [ 'composer']
      volumes:
        - ./app:/app
      networks:
        - backend
```

Now, when we run command

```shell
docker-compose up
```

We will have container with php, and ready to use container with Composer.

To run some composer command, we will use next:

```shell
docker-compose run --rm composer init
```

After this steps we will have robust app with high cohesion between PHP and Composer, which allow as always be sure that our app has all required packages and extensions installed.