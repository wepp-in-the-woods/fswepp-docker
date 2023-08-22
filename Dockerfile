FROM ubuntu

COPY ./keyboard /etc/default/keyboard
ENV DEBIAN_FRONTEND noninteractive

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


## Install Wine
RUN apt-get install -y xvfb
RUN Xvfb :0 -screen 0 1024x768x16 &

RUN dpkg --add-architecture i386
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key -O winehq.key
RUN mv winehq.key /usr/share/keyrings/winehq-archive.key
RUN echo "deb [signed-by=/usr/share/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ focal main" | tee /etc/apt/sources.list.d/winehq.list
RUN apt-get update
RUN apt-get install -y --install-recommends winehq-stable
RUN apt-get install -y winetricks

#RUN winetricks -q allfonts

# Set up Wine to be used by the root user (adjust as needed)
ENV WINEPREFIX /root/.wine
ENV WINEARCH win64

# If your application needs a GUI, set up xvfb to create a "fake" display
ENV DISPLAY :0

# Run winetricks to install required components
# Use the silent install (-q) option to avoid prompts
#RUN winetricks -q mfc42

## Set Timezone
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Los_Angeles apt-get -y install tzdata
RUN dpkg-reconfigure -f non-interactive tzdata

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
RUN rm -R /var/www/html
COPY ./000-default.conf /etc/apache2/sites-enabled/
RUN echo 'ServerName 0.0.0.0' >> /etc/apache2/apache2.conf
CMD apachectl -D FOREGROUND

EXPOSE 80

