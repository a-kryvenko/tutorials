# Docker environment for Laravel web application

As all other web applications, laravel also can be built on set of docker containers.
Usage of containers allow us to use standard environment on dev, test and production servers.

Common laravel application require next services: NGINX, PHP 8.1, Composer, Redis, MySQL, MailHog and NodeJS for dev environment.
All this software will be included as a separate docker containers.

We will use [laravel-webserver](https://github.com/a-kryvenko/laravel-10-webserver "laravel-webserver") for environment installation.

1.  Prepare server using instruction: [configure server for web applications](https://github.com/a-kryvenko/tutorials/tree/master/docs/ServerConfiguration.md "Configure server for web applications")
2.  Connect to you server via SSH:
    ```shell
    ssh www@you_server_ip
    ```
3.  Clone environment repository
    ```shell
    git clone git@github.com:a-kryvenko/laravel-10-webserver.git website
    ``` 
4.  Copy environment config example
    ```shell
    cp website/.env.example website/.env
    ```
5.  Set up environment variables (database access, emails, docker-compose files, etc.)

6. \[Optional\]. If you need SSL certificates - create nginx-proxy for managing them
    ```shell
    ./nginx-proxy-up.sh
    ```
    
7. Build and up server
    ```shell
    cd website
    ```

    ```shell
    docker-compose build
    ```
    
    ```shell
    docker-compose up -d
    ```

8.  Init crontab (in fact, in future you will need to run this command each time when you add new crontab record)
    ```shell
    ./cgi-bin/prepare-crontab.sh
    ```

Now our webserver is ready and we can create laravel project

1.  Open www folder and init laravel repository
    ```shell
    mkdir www
    ```
    
    ```shell
    docker-compose run --rm composer create-project laravel/laravel .
    ```

2.  Or, if you already have repository with you site, then
    ```shell
    mkdir www
    ```

    ```shell
    cd www
    ```

    ```shell
    git clone #you_repository_path# .
    ```

3.  Copy laravel environment variables file

    ```shell
    cp www/.env.example www/.env
    ```

4.  Set up laravel variables. Use same values for database, redis and mailer
5.  Build laravel application
    ```shell
    docker-compose run --rm composer install --no-dev
    docker-compose run --rm artisan key:generate
    docker-compose run --rm artisan storage:link
    docker-compose run --rm artisan migrate
    ```

Our application now is ready for use!