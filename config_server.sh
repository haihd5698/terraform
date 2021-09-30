#!bin/bash
sudo apt update -y
sudo apt install nginx php-mysql php-fpm -y
cd /var/www/
sudo git clone https://github.com/WordPress/WordPress.git wordpress
sudo chmod 777 -R wordpress
sudo echo "server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/wordpress;
        index index.html index.htm index.php index.nginx-debian.html;
        server_name _;
        location / {
                try_files \$uri \$uri/ =404;
        }
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;

        }
}" > /etc/nginx/sites-available/default
sudo systemctl restart nginx.service