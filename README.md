Gatsby Blog CMS

## Run
```
$ docker-compose up -d 
```

## Optional db setting

```
$ docker-compose exec db bash
$ mysql -u root -p

mysql> show databases;
mysql> GRANT ALL ON gatsby-blog.* TO 'wp'@'%' IDENTIFIED BY 'wp';
mysql> FLUSH PRIVILEGES;
mysql> EXIT;

$ exit;
```

## Rebuild image
```
$ docker-compose stop
$ docker-compose up -d --build
```

## View logs
```
$ docker logs -f gatsby-blog
```

## Restart php-fpm7 service
```
$ docker exec -it gatsby-blog /bin/sh

docker-host> s6-svc -r /var/run/s6/services/php-fpm7/
```

## Install composer packages with docker image
```
docker run --rm --interactive --tty \
--volume $PWD:/app \
composer:1.9.3 require roots/wordpress:5.4.2
```

## S6 Overlay
https://skarnet.org/software/s6/s6-supervise.html
https://skarnet.org/software/s6/s6-svc.html

## Requirements

- PHP >= 7.1
- Composer - [Install](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)

## Build Docker image

docker build --tag gatsby-blog:1.0 .
docker run -d -p 8080:8080 --name gatsby-blog gatsby-blog:1.0

## Build Production Docker image

docker-compose -f docker-compose.prod.yml up -d

## Docker cleanup

docker ps -a -f status=exited
docker rm $(docker ps -a -f status=exited -q)
docker images prune


##Buildpacks FIX

READ: https://stackoverflow.com/questions/60468025/dokku-php-extension-mbstring-is-missing-when-deploying-laravel-application