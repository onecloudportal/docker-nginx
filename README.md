# docker-nginx

This image installs [Nginx](http://nginx.org/), an open-source, high-performance web server, reverse proxy and load balancer.

## Components

The stack comprises the following components:

Name        | Version       | Description
------------|---------------|------------
Nginx       | Lastest       | HTTP server & Reverse proxy
Ubuntu      | Trusty        | Operating system

## Usage

### 1. Start the Container

#### A. Basic Usage

To start your container with:

* Ports 80, 443 exposed
* A named container (**nginx**)

Do: 

```no-highlight
sudo docker run -d -p 80:80 -p 443:443 --name nginx dell/nginx
```

<a name="advanced-usage"></a>
#### B. Advanced Usage

To start your container with:

* Ports 80, 443 exposed
* A named container (**nginx**)
* Three data volumes on the host (which will survive a restart or recreation of the container). The Nginx website configuration files are available in **/etc/nginx/sites-enabled**, the application files in **/data/www**, and the Nginx log files in **/var/log/nginx**.

Do: 

```no-highlight
sudo docker run -d -p 80:80 \
    -p 443:443 \
    -v /etc/nginx/sites-enabled:/etc/nginx/sites-enabled \
    -v /var/log/nginx:/var/log/nginx  \
    -v /data/www:/data/www \
    --name nginx \
    dell/nginx
```

### 2. Test Your Deployment
The default site created by the container comprises a simple "Hello World" home page. Please access the site as follows (use **localhost** or **127.0.0.1** if you are running the container locally):
```no-highlight
http://<ip address>
```

Or with cURL:

```no-highlight
curl http://<ip address>
```

### 3. Edit the Nginx Configuration

If you used the volume mapping option as listed in the [Advanced Usage](#advanced-usage), you can directly change the Nginx configuration via **/etc/nginx/sites-enabled/default** on the host. To reload the configuration, enter the container using [nsenter](https://github.com/dell-cloud-marketplace/additional-documentation/blob/master/nsenter.md), and do:

```no-highlight
nginx -s reload
```

## Loading your custom application

You can replace the default "Hello World" application, located under **/data/www**, with your own website content. If you used the volume mapping option explained in the [Advanced Usage](#advanced-usage), you can directly copy the content of your custom application to **/data/www** on the host.

### Example: Enable PHP

Enter the container using [nsenter](https://github.com/dell-cloud-marketplace/additional-documentation/blob/master/nsenter.md), and install **php5-fpm**:

```no-highlight
apt-get install php5-fpm
```

Next, edit the configuration file **/etc/nginx/sites-enabled/default**. Add **index.php** to the index line:

```no-highlight
index index.php index.html index.htm;
```
Replace the **location ~ \.php$ { ... }** section with the following lines:

```no-highlight
location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
}
```

Save the configuration file. Next, create file **info.php**, or copy your website content, under **/data/www**

```no-highlight
echo '<?php phpinfo(); ?>' > /data/www/info.php
```

Restart **php5-fm**:

```no-highlight
service php5-fpm restart
```

Reload the Nginx configuration:

```no-highlight
nginx -s reload
```

Finally, access your PHP page:

```no-highlight
http://localhost/info.php (or any file of your website)
```

### SSL Support
The container supports SSL, via a self-signed certificate. **We strongly recommend that you connect via HTTPS**, if the container is running outside your local machine (e.g. in the Cloud), and your site requests confidential information (e.g. passwords). Your browser will warn you that the certificate is not trusted. If you are unclear about how to proceed, please consult your browser's documentation on how to accept the certificate.

## Nginx as a Reverse Proxy
Nginx is often used as reverse proxy server - a go-between or intermediary that retrieves resources on behalf of a client from one or more servers. These resources are then returned to the client as though they originated from the server itself.

We can illustrate this via a simple example. In this, Nginx:

* Serves images from a local directory on port 80 and;
* Sends all other requests to a site running on port 8080 of the localhost (in reality, this would usually be a different host)

Set the contents of configuration file **/etc/nginx/sites-enabled/default** to:

```no-highlight
server {
    listen 8080;

    root /data/www/app;

    location / {
    }
}

server {
    listen 80 default_server;

    location / {
         proxy_pass http://localhost:8080;
    }

    location ~ \.(gif|jpg|png)$ {
        root /data/www/images;
    }
}
```

Next, enter the container using [nsenter](https://github.com/dell-cloud-marketplace/additional-documentation/blob/master/nsenter.md), and reload the configuration:

```no-highlight
nginx -s reload
```

Images should be stored under **/data/www/images** and the rest of the content under **/data/www/app**.

This server will filter requests ending with .gif, .jpg, or .png and map them to the **/data/www/images** directory and pass all other requests to the proxied site. 

## Nginx configuration
For other information on how to use Nginx, please refer to the [Beginner’s Guide](http://nginx.org/en/docs/beginners_guide.html).

## Reference

### Image Details

Inspired by [tutum/nginx](https://github.com/tutumcloud/tutum-docker-nginx)

Pre-built Image | [https://registry.hub.docker.com/u/dell/nginx](https://registry.hub.docker.com/u/dell/nginx) 
