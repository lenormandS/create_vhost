#!/bin/sh

version(){
	echo "${VERSION}"
}

usage(){
usage="$(basename $0) -c <name> [-e <extension>] [-p <port>] [-i <ip adress>]
	-c	Create new configuration and folder
	-e	Extension of index [ default : HTML ]
	-p	Port of VirtualHost [ default : 80 ]
	-i	IP address of VirtualHost [ default : 127.0.0.1 ]
	-d	Delete conf file
"

echo "$usage"
}

create_new_conf(){
        if [ whoami != "root" ]
        then
            echo "Please, use as root"
        else
            local PATH_FOLDER="${SITES_PATH}/${2}"
            if [ -d "${PATH_FOLDER}" ]
            then
                    echo "FOLDER EXIST - ABORT"
                    exit
            else
                    mkdir "${PATH_FOLDER}"
                    chmod -R 777 "${PATH_FOLDER}"
                    if [ ! -z "${EXTENSION_SUFFIX}" ];then
                            EXTENSION_DEFAULT="${EXTENSION_SUFFIX}"
                    fi
                    touch "${PATH_FOLDER}/index.${EXTENSION_DEFAULT}"
                    echo "IT'S WORK : ${2}" >> "${PATH_FOLDER}/index.${EXTENSION_DEFAULT}"
                    include_conf "${2}"
                    update_host "${2}"
                    reload_apache "${2}"
            fi
        fi
}

include_conf(){
if [ ! -z "${PORT_VALUE}" ];then
	DEFAULT_PORT="${PORT_VALUE}"
fi
conf="
<VirtualHost *:${DEFAULT_PORT}>
	ServerAdmin webmaster@localhost
	ServerName local.${1}

	DocumentRoot ${PATH_FOLDER}
	<Directory />
		Options FollowSymLinks
		AllowOverride All
	</Directory>
	<Directory ${PATH_FOLDER}>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>

	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	<Directory "/usr/lib/cgi-bin">
		AllowOverride All
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>

	ErrorLog /var/log/apache2/error.log

	LogLevel warn

	CustomLog /var/log/apache2/access.log combined

    Alias /doc/ "/usr/share/doc/"
    <Directory "/usr/share/doc/">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride All
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>
</VirtualHost>
"
echo "$conf" >> "${APACHE_SITES}/${1}.conf"
}


update_host(){
	if [ ! -z "${IP_VALUE}" ];then
		DEFAULT_IP="${IP_VALUE}"
	fi
	update="${DEFAULT_IP}	local.${1}"
	sed -i "1s/^/$update\n/" "${HOSTS_PATH}"
}

reload_apache(){
	echo "Activate new config ? (Y/n)"
	read answer
	case "${answer}" in
		y|Y|"")
			a2ensite "${1}.conf"
			service apache2 reload
			exit
			;;
		n|N)
			echo "New config create - GoodBye"
			exit
			;;
		*)
			echo "INVALID ARGUMENT"
			exit
			;;
	esac
exit
}

deleteFolderConf(){
	for variable in $(ls "${APACHE_SITES}" | grep "${@}");do
		echo "\033[1;31m ($#) CONF FOUND : \033[4;32m${variable}\033[0m \033[0m"
	done
	if [ ! -n "${variable}" ];then
		echo "NO CONFIG FOUND FOR : ${@} - ABORT"
		exit
	else
		echo "CONFIG TO DELETE : (type name)"
		read answer
		test=$(find "${HOSTS_PATH}" -type f | xargs grep -Hn "${answer}" | cut -c12-12)
		sed -i "${test} d" "${HOSTS_PATH}"
		rm -rf "${SITES_PATH}/${answer}" && rm -rf "${APACHE_SITES}/${answer}.conf"
		a2dissite "${answer}.conf"
		service apache2 restart
	fi

}
