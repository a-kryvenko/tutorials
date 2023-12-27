# PHP configuration to work with PostgresSQL in Docker environment

This tutorial describe how to configure php to work with [PostgresSQL](https://www.postgresql.org/) database in Docker containers.

We need next Dockerfile for PHP service

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

CMD php-fpm -y /usr/local/etc/php-fpm.conf -R
```

In this file we installed PHP with PDO extensions to work with PostgresQL.

Next, create .env file with database connection credentials:

```text
DB_USER=pguser
DB_PASSWORD=dbpass
DB_DATABASE=playground
```

Next, create docker-compose file to define containers for PHP and database:

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
      depends_on:
        - db
      networks:
        - database
        - backend
  
    db:
      image: postgres
      container_name: playgroundDatabase
      restart: unless-stopped
      environment:
        POSTGRES_PASSWORD: ${DB_PASSWORD}
        POSTGRES_USER: ${DB_USER}
        POSTGRES_DB: ${DB_DATABASE}
      networks:
        - database
  
  networks:
    backend:
      driver: bridge
    database:
      driver: bridge
```

Now we can create connection to PostgresSQL in our PHP file:

```php
$pdo = new PDO('pgsql:host=db;dbname=' . $databaseName, $databaseUser, $databasePassword);
```

Details of work with PostgresSQL described in [official documentation](https://www.postgresql.org/about/featurematrix/ "PostgersQL official documentation") of PostgresSQL.
