FROM debian:latest
MAINTAINER Quentin COUMES <coumes.quentin@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1
EXPOSE 80
WORKDIR /home/wims

RUN apt-get -qq -y update
RUN apt-get -qq -y upgrade

RUN apt-get -qq install -y --no-install-recommends \
    python3 \
    make \
    sudo \
    g++ \
    texlive-base \
    gnuplot \
    build-essential \
    flex \
    bison \
    maxima \
    perl \
    liburi-perl \
    libgd-dev \
    wget \
    autoconf ant \
    ldap-utils \
    libwebservice-validator-html-w3c-perl \
    qrencode \
    fortune \
    unzip \
    libgmp-dev \
    openbabel \
    apt-transport-https \
    gnupg2 \
    dirmngr \
    apache2 \
    systemd

# Installing pip3
RUN wget "https://bootstrap.pypa.io/get-pip.py" && \
    python3 get-pip.py
RUN rm get-pip.py

RUN pip3 install requests

# Installing Git from source
RUN apt-get install -y --no-install-recommends git

# Installing Wims 4.17c
RUN adduser --disabled-password --gecos "" wims
RUN adduser wims sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER wims
RUN sudo chown -R wims:wims .
RUN wget --no-check-certificate https://sourcesup.renater.fr/frs/download.php/latestfile/531/wims-4.17c.tgz
RUN tar xzf wims-4.17c.tgz
RUN rm wims-4.17c.tgz
RUN yes 2 | ./compile --modules 1> /dev/null

USER root
RUN ./bin/setwrapexec
RUN ./bin/setwimsd
RUN /bin/bash -c "source /etc/apache2/envvars"
RUN echo 'ServerName 172.17.0.2' >> /etc/apache2/apache2.conf
RUN echo 'manager_site=172.17.0.2' > log/wims.conf
RUN echo 'site_manager=2' >> log/wims.conf
RUN echo "threshold1=$(($(cat /proc/cpuinfo | grep processor | wc -l) * 150))" >> log/wims.conf
RUN echo "threshold2=$(($(cat /proc/cpuinfo | grep processor | wc -l) * 300))" >> log/wims.conf
COPY config/myself /home/wims/log/classes/.connections/
COPY config/.def /home/wims/log/classes/9001/

RUN a2enmod cgi
#ENTRYPOINT ./bin/apache-config && service apache2 restart
