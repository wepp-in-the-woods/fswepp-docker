FROM ubuntu:20.04

COPY ./keyboard /etc/default/keyboard
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y python3.9 python3.9-dev
RUN apt-get install -y apache2
RUN apt-get install -y php
RUN apt-get install -y libapache2-mod-php
RUN apt-get install -y php-mysql
RUN apt-get install -y wget
RUN apt-get install -y gnupg
RUN apt-get install -y gnuplot-qt
RUN apt-get install -y libxml-simple-perl
RUN apt install -y curl
RUN apt-get install -y vim


## Install Wine
RUN dpkg --add-architecture i386
RUN wget -nc http://dl.winehq.org/wine-builds/winehq.key
RUN mv winehq.key /usr/share/keyrings/winehq-archive.key
RUN wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
RUN mv winehq-focal.sources /etc/apt/sources.list.d/
RUN apt-get update
RUN apt-get install -y --install-recommends winehq-stable

## Set Timezone
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Los_Angeles apt-get -y install tzdata
RUN dpkg-reconfigure -f non-interactive tzdata

## Configure Apache
RUN a2enmod cgid
RUN rm -R /var/www/html
COPY ./000-default.conf /etc/apache2/sites-enabled/
RUN echo 'ServerName 0.0.0.0' >> /etc/apache2/apache2.conf
CMD /etc/init.d/apache2 stop && /etc/init.d/apache2 start && /bin/bash

EXPOSE 80

