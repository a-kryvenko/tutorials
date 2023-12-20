# SSL certificates and NGINX proxy on Docker

To avoid responsibility of managing SSL certificates, recommended to used specified software for these tasks.
For do it, we recommend [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy "Github nginx proxy") and [acme-companion](https://github.com/nginx-proxy/acme-companion "Github acme companion").

You can create services manually, or use our [docker-nginx-proxy](https://github.com/a-kryvenko/docker-nginx-proxy "Github nginx-proxy") script.

# Manual installation
-------------------

First of all, we need to create network for nginx proxy

```shell
docker network create nginx-proxy-network
```

Next, up container with nginx proxy

```shell
docker run --detach \
  --rm \
  --name nginx-proxy \
  --publish 80:80 \
  --publish 443:443 \
  --net nginx-proxy-network \
  --env DEFAULT_ROOT="503 $(pwd)/maintenance.html" \
  --volume certs:/etc/nginx/certs \
  --volume vhost:/etc/nginx/vhost.d \
  --volume html:/usr/share/nginx/html \
  --volume /var/run/docker.sock:/tmp/docker.sock:ro \
  nginxproxy/nginx-proxy:alpine
```

And then, up container with acme-companion

```shell
docker run --detach \
  --rm \
  --name nginx-proxy-acme \
  --net nginx-proxy-network \
  --volumes-from nginx-proxy \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --volume acme:/etc/acme.sh \
  --env "DEFAULT_EMAIL=mail@mail.com" \
  nginxproxy/acme-companion
```

Nginx-proxy script
------------------

Download ready-to-use script for this task:

```shell
git clone git@github.com:a-kryvenko/docker-nginx-proxy.git nginx-proxy
```

```shell
./nginx-proxy/nginx-proxy-up.sh
```

Website configuration
---------------------

Now we have proxy, which will be responsible for managing SSL certificates and frontline of handling user requests.

To make our website available for visitors, we need now to remove ports binding from it (80, 443), expose 80 port instead. And set environment variables for each website NGINX docker container, which hidden behind our proxy:

1.  HOSTNAME = example.com (where example.com is you website)
2.  VIRTUAL\_HOST = example.com (where example.com is you website)
3.  LETSENCRYPT\_HOST = example.com (where example.com is you website)

As example, for docker-compose it looks like:

```yaml
version: '3'
  services:
    nginx:
      expose:
        - "80"
      environment:
        - HOSTNAME=${APP_NAME}
        - APP_NAME=${APP_NAME}
        - VIRTUAL_HOST=${APP_NAME}
        - LETSENCRYPT_HOST=${APP_NAME}
      networks:
        - nginx-proxy-network
  
  networks:
    nginx-proxy-network:
      external: true
```