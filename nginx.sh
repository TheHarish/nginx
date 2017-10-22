#!/bin/bash

# Remove apache and installs nginx
# Usage: 
#	nginx.sh [command] 
#Commands :
#	install
#	uninstall
#	configure
#	start
#	stop
#	restart
#	log


function uninstallApache() {
  sudo apt-get --purge remove apache2*
}

function installNginx() {
  echo $(tput setaf 6) "Need to run apt-get update" $(tput sgr0)
  sudo apt-get update && sudo apt-get dist-upgrade
  echo $(tput setaf 6) "Installing nginx" $(tput sgr0)
  sudo apt-get install nginx
}

function uppercase {
  echo "${1^^}"
}

function configureNginx() {

  echo $(tput setaf 6) "Configuring nginx" $(tput sgr0)

  sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
  sudo rm /etc/nginx/sites-available/default

  read -p $(tput setaf 2)$(tput bold)"Enter server names (eg: site.com www.site.com mydomain.site.com) : "$(tput sgr0) server

  read -p $(tput setaf 2)$(tput bold)"Enter internal ip for app : "$(tput sgr0) appinternalip

  read -p $(tput setaf 2)$(tput bold)"Enter internal port for app : "$(tput sgr0) appinternalport

  echo "server {
  	listen 80 default_server;
 
	root /usr/share/nginx/html;
    	index index.html index.htm;

    	server_name $server;

	# listen 443 ssl;
	# ssl_certificate /home/harish/projects/nginx/cert/fullchain.pem;
	# ssl_certificate_key /home/harish/projects/nginx/cert/privkey.pem;
 
	# ssl_session_cache  builtin:1000  shared:SSL:10m;
	# ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	# ssl_prefer_server_ciphers on;

	# ssl_ciphers \"ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS\";

        # if (\$scheme != \"https\") {
        # 	return 301 https://\$host\$request_uri;
	# }


    	location / {
      		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
	      	proxy_set_header Host \$host;
	      	proxy_set_header X-NginX-Proxy true;

	      	proxy_pass http://$appinternalip:$appinternalport;
	      	proxy_redirect off;
		# proxy_redirect http://$appinternalip:$appinternalport https://$server;

    	}

	# error.html need to be created and placed inside /usr/share/nginx/html
    	error_page 400 500 502 503 504 /error.html;
    	location = /error.html {
      		root /usr/share/nginx/html;
      		internal;
    	}


  }
  "  | sudo tee /etc/nginx/sites-available/default > /dev/null

  echo "<h1>Welcome</h1>
  <p>Proxy for $server is running</p>" | sudo tee /usr/share/nginx/html/index.html > /dev/null

  echo "<h1>Error</h1>
  <p>An error has occured. Please contact administrator for $server</p>" | sudo tee /usr/share/nginx/html/error.html > /dev/null

  sudo service nginx restart

  echo $(tput setaf 6) "Config completed @ etc/nginx/sites-available/default" $(tput sgr0)
}

if [[ $(uppercase $1) == "" ]]; then
  echo $(tput setaf 6)"Usage: 
	nginx.sh [command] 
Commands :
	install
	uninstall
	configure
	start
	stop
	restart
	log" $(tput sgr0)

fi

if [[ $(uppercase $1) == "INSTALL" ]]; then
  uninstallApache
  installNginx
  configureNginx
fi

if [[ $(uppercase $1) == "UNINSTALL" ]]; then
  sudo service nginx stop
  sudo apt-get purge --auto-remove nginx nginx-common
fi

if [[ $(uppercase $1) == "CONFIGURE" ]]; then
  configureNginx
fi

if [[ $(uppercase $1) == "START" ]]; then
  sudo service nginx start
fi

if [[ $(uppercase $1) == "STOP" ]]; then
  sudo service nginx stop
fi

if [[ $(uppercase $1) == "RESTART" ]]; then
  sudo service nginx restart
fi

if [[ $(uppercase $1) == "LOG" ]]; then
  echo "$(tput setaf 6)"
  set -x
  cat /var/log/nginx/error.log
  set +x
  echo "$(tput sgr0)"
fi
