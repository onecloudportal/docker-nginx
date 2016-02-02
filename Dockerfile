FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Update existing packages.
RUN apt-get update 

# Ensure UTF-8
RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    export LC_ALL=en_US.UTF-8 && \
    export LANGUAGE=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Install packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get -y install \
        supervisor \
        openssl \
        nginx && \ 
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf
    
# Clean package cache
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*

# Add supervisor configuration and script
COPY start-nginx.sh /start-nginx.sh
COPY supervisord-nginx.conf /etc/supervisor/conf.d/supervisord-nginx.conf

# Add sites-enabled
COPY sites-enabled/ /sites-enabled
RUN rm -rf /etc/nginx/sites-enabled/*

# Add Hello world app
COPY /hello-world-nginx /hello-world-nginx/

# Generate self-signed certificate to enable HTTPS
RUN mkdir /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout /etc/nginx/certs/nginx.key -out /etc/nginx/certs/nginx.crt \
       -subj '/O=Dell/OU=MarketPlace/CN=www.dell.com'

# Add startup script and make it executable.
COPY run.sh /run.sh
RUN chmod +x /*.sh

# Define Nginx mountable directories.
VOLUME ["/data/www", "/etc/nginx/sites-enabled", "/var/log/nginx"]

# Expose HTTP and HTTPS ports
EXPOSE 80
EXPOSE 443

CMD ["/run.sh"]
