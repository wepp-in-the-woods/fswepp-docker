FROM ubuntu:20.04

# based on https://github.com/suchja/wine
ENV WINE_MONO_VERSION 0.0.8
USER root

COPY ./keyboard /etc/default/keyboard

# Set noninteractive installation
ARG DEBIAN_FRONTEND=noninteractive

# Set the timezone
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata


# Install some tools required for creating the image
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                curl \
                unzip \
                ca-certificates \
                xvfb

# Install wine and related packages
RUN dpkg --add-architecture i386 \
                && apt-get update -qq \
                && apt-get install -y -qq \
                                wine-stable \
                                winetricks \
                                wine32 \
                                libgl1-mesa-glx:i386 \
                && rm -rf /var/lib/apt/lists/*


RUN apt-get update
RUN apt-get install -y apt-utils
#RUN apt-get install -y python3.9 python3.9-dev
RUN apt-get install -y python3 python3-dev
RUN apt-get install -y apache2
RUN apt-get install -y php
RUN apt-get install -y libapache2-mod-php
RUN apt-get install -y php-mysql
RUN apt-get install -y wget
RUN apt-get install -y gnupg
RUN apt-get install -y gnuplot-qt
RUN apt-get install -y libxml-simple-perl
RUN apt-get install -y libcgi-session-perl
RUN apt install -y curl
RUN apt-get install -y vim

## Move perl dependencies
COPY var/www/cgi-bin/BAERTOOLS/baer-db/Query.pl /etc/perl/
COPY var/www/cgi-bin/BAERTOOLS/baer-db/PageCommon.pl /etc/perl/
COPY var/www/cgi-bin/BAERTOOLS/baer-db/ShowProj.pl /etc/perl/

# on host
# > sudo groupadd webgroup
# > sudo usermod -aG webgroup your_username
# > sudo chown -R :webgroup fswepp-docker
# > sudo chmod g+s fswepp-docker
# > getent group webgroup | cut -d: -f3
RUN groupadd -g 1002 webgroup && \
    usermod -aG webgroup www-data

## Configure Apache
RUN a2enmod cgid
RUN a2enmod headers
RUN rm -R /var/www/html
COPY ./000-default.conf /etc/apache2/sites-enabled/
RUN echo 'ServerName 0.0.0.0' >> /etc/apache2/apache2.conf
CMD apachectl -D FOREGROUND

RUN winetricks -q

EXPOSE 80

