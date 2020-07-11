FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

# Install deps
RUN apt --yes update
RUN apt --yes install apache2
RUN apt --yes install php libapache2-mod-php php-curl
RUN apt --yes install curl git
RUN apt --yes install zip unzip php-zip

# Setup apache
# SHELL ["/bin/bash", "-c"]
RUN sed -i "s/DirectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g" /etc/apache2/mods-enabled/dir.conf
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2ensite 000-default.conf
RUN mkdir /var/www/html/certs/
RUN service apache2 restart
RUN touch temp.txt

RUN echo "    <Directory /var/www/html>" >> temp.txt 
RUN echo "        Options Indexes FollowSymLinks" >> temp.txt
RUN echo "        AllowOverride All"   >> temp.txt
RUN echo "        Require all granted" >> temp.txt
RUN echo "    </Directory>" >> temp.txt
RUN echo "      SSLEngine on" >> temp.txt
RUN echo "      SSLProtocol -all +TLSv1.3 +TLSv1.2" >> temp.txt
RUN echo "      SSLCertificateFile /var/www/html/certs/buhwild2020.crt" >> temp.txt
RUN echo "      SSLCertificateKeyFile /var/www/html/certs/buhwild2020.key" >> temp.txt
RUN echo "      SSLCertificateChainFile /var/www/html/certs/buhwild2020-ca.crt" >> temp.txt
RUN echo "      ServerName o365.backupheroes.co.uk" >> temp.txt

RUN sed -i '/<VirtualHost.*/r temp.txt' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/:80*/:443/g' /etc/apache2/sites-available/000-default.conf

RUN sed -i "s/max_execution_time.*/max_execution_time = 0/g" /etc/php/7.4/apache2/php.ini

# Setup composer
RUN curl -sS https://getcomposer.org/installer | /usr/bin/php && /bin/mv -f composer.phar /usr/local/bin/composer
RUN git clone https://github.com/nielsengelen/vbo365-rest.git
RUN cp -r vbo365-rest/. /var/www/html/
RUN cd /var/www/html && composer install
# mapping
RUN mkdir /var/www/html/vbo-config
RUN mkdir /var/www/html/vbo-certs
RUN mv /var/www/html/config.php /var/www/html/vbo-config
RUN mv /var/www/html/setup.php /var/www/html/vbo-config
RUN ln -s /var/www/html/vbo-config/config.php /var/www/html/config.php
RUN ln -s /var/www/html/vbo-config/setup.php /var/www/html/setup.php
RUN ln -s /var/www/html/vbo-certs/buhwild2020-ca.crt /var/www/html/certs
RUN ln -s /var/www/html/vbo-certs/buhwild2020.crt /var/www/html/certs
RUN ln -s /var/www/html/vbo-certs/buhwild2020.key /var/www/html/certs
RUN chown -R www-data:www-data /var/www/html/vbo-config
RUN chown -R www-data:www-data /var/www/html/vbo-certs

CMD [ "/usr/sbin/apachectl", "-D", "FOREGROUND" ]