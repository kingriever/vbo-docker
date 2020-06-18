FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

# Install deps
RUN apt --yes update
RUN apt --yes install apache2
RUN apt --yes install php libapache2-mod-php
RUN apt --yes install curl git
RUN apt --yes install zip unzip php-zip

# Setup apache
# SHELL ["/bin/bash", "-c"]
RUN sed -i "s/DirectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g" /etc/apache2/mods-enabled/dir.conf
RUN a2enmod rewrite
RUN service apache2 restart
RUN touch temp.txt

RUN echo "    <Directory /var/www/html>" >> temp.txt 
RUN echo "        Options Indexes +FollowSymLinks MultiViews" >> temp.txt
RUN echo "        AllowOverride All"   >> temp.txt
RUN echo "        Require all granted" >> temp.txt
RUN echo "    </Directory>" >> temp.txt

RUN sed -i '/<VirtualHost.*/r temp.txt' /etc/apache2/sites-available/000-default.conf
RUN touch /var/www/html/.htaccess
RUN echo "RewriteEngine on" > /var/www/html/.htaccess

# Setup composer
RUN curl -sS https://getcomposer.org/installer | /usr/bin/php && /bin/mv -f composer.phar /usr/local/bin/composer
RUN git clone https://github.com/nielsengelen/vbo365-rest.git
RUN cp -r vbo365-rest/* /var/www/html/
RUN cd /var/www/html && composer install

RUN mkdir /root/vbo-config
RUN mv /var/www/html/config.php /root/vbo-config
RUN mv /var/www/html/setup.php /root/vbo-config
RUN ln -s /root/vbo-config/config.php /var/www/html/config.php
RUN ln -s /root/vbo-config/setup.php /var/www/html/setup.php

CMD [ "/usr/sbin/apachectl", "-D", "FOREGROUND" ]