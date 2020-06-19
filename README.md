# vbo-docker

This readme is very rough, will update soon

Currently you need to alter permissions and ownership on the host as the website wants you do delete the setup.php so setup.php and config.php are exposed to the docker folder

sudo chown -R www-data:www-data config

sudo chmod 664 config/config.php
sudo chmod 664 config/setup.php

The compose file also doesn't bring the container up after reboot, as I used a systemctl custom services to launch a script to run docker-compose up -d

To do

Script permissions to the host
