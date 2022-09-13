# NextCloud server

This is dockerized nextcloud server using docker-compose.

I have used [NginxProxyManager](https://nginxproxymanager.com/) to handle the proxy.

## Setup:

First run the proxy:
```sh
cd proxy
docker-compose up -d
```

To handle the proxy setting, open 'serverIP:81'. The default email is `admin@example.com`, and the default password is `changeme`.

Then run the nextcloud:
```sh
cd nextcloud
docker-compose up -d
```
