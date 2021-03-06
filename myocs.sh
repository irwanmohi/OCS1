#!/bin/bash

if [ $USER != 'root' ]; then
	echo "Anda harus menjalankan ini sebagai root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;

if [[ -e /etc/debian_version ]]; then
	#OS=debian
	RCLOCAL='/etc/rc.local'
else
	echo "Anda tidak menjalankan script ini pada OS Debian"
	exit
fi

vps="FNS";

if [[ $vps = "FNS" ]]; then
	source="http://script.fawzya.net/premium"
else
	source="http://script.fawzya.net/premium"
fi

# go to root
cd

MYIP=$(wget -qO- ipv4.icanhazip.com);

# check registered ip
wget -q -O daftarip https://raw.githubusercontent.com/irwanmohi/OCS1/master/ip.txt
if ! grep -w -q $MYIP daftarip; then
	echo "Maaf, hanya IP yang terdaftar yang bisa menggunakan script ini!"
	if [[ $vps = "FNS" ]]; then
		echo "Powered by Ibnu Fachrizal"
	else
		echo "Powered by Ibnu Fachrizal"
	fi
	rm -f /root/daftarip
	exit
fi

#https://github.com/adenvt/OcsPanels/wiki/tutor-debian

clear
echo ""
echo "Saya perlu mengajukan beberapa pertanyaan sebelum memulai setup"
echo "Anda dapat membiarkan pilihan default dan hanya tekan enter jika Anda setuju dengan pilihan tersebut"
echo ""
echo "Pertama saya perlu tahu password baru user root MySQL:"
read -p "Password baru: " -e -i ibnu DatabasePass
echo ""
echo "Terakhir, sebutkan Nama Database untuk OCS Panels"
echo "Tolong, gunakan satu kata saja, tidak ada karakter khusus selain Underscore (_)"
read -p "Nama Database: " -e -i OCS_PANEL DatabaseName
echo ""
echo "Oke, itu semua saya butuhkan. Kami siap untuk setup OCS Panels Anda sekarang"
read -n1 -r -p "Tekan sembarang tombol untuk melanjutkan..."

#apt-get update
apt-get update -y
apt-get install build-essential expect -y

apt-get install -y mysql-server

#mysql_secure_installation
so1=$(expect -c "
spawn mysql_secure_installation; sleep 3
expect \"\";  sleep 3; send \"\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect eof; ")
echo "$so1"
#\r
#Y
#pass
#pass
#Y
#Y
#Y
#Y

chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/

apt-get install -y nginx php5 php5-fpm php5-cli php5-mysql php5-mcrypt
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
curl $source/ocs/nginx.conf > /etc/nginx/nginx.conf
curl $source/ocs/vps.conf > /etc/nginx/conf.d/vps.conf
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf

useradd -m fns
mkdir -p /home/fns/public_html
echo "<?php phpinfo() ?>" > /home/fns/public_html/info.php
chown -R www-data:www-data /home/fns/public_html
chmod -R g+rw /home/fns/public_html
service php5-fpm restart
service nginx restart

apt-get -y install zip unzip
cd /home/fns/public_html
wget $source/leeocs.zip
unzip leeocs.zip
#rm -f LTEOCS.zip
chown -R www-data:www-data /home/fns/public_html
chmod -R g+rw /home/fns/public_html

#mysql -u root -p
so2=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE DATABASE IF NOT EXISTS $DatabaseName;EXIT;\r\"
expect eof; ")
echo "$so2"
#pass
#CREATE DATABASE IF NOT EXISTS OCS_PANEL;EXIT;

chmod 777 /home/fns/public_html/config
chmod 777 /home/fns/public_html/config/inc.php
chmod 777 /home/fns/public_html/config/route.php


clear
echo "Buka Browser, akses alamat http://$MYIP:81/ dan lengkapi data2 seperti dibawah ini!"
echo "Database:"
echo "- Database Host: localhost"
echo "- Database Name: $DatabaseName"
echo "- Database User: root"
echo "- Database Pass: $DatabasePass"
echo ""
echo "Admin Login:"
echo "- Username: sesuai keinginan"
echo "- Password Baru: sesuai keinginan"
echo "- Masukkan Ulang Password Baru: sesuai keinginan"
echo ""
echo "Klik Install dan tunggu proses selesai, kembali lagi ke terminal dan kemudian tekan tombol [ENTER]!"

sleep 3
echo ""
read -p "Jika Step diatas sudah dilakukan, silahkan Tekan tombol [Enter] untuk melanjutkan..."
echo ""
read -p "Jika anda benar-benar yakin Step diatas sudah dilakukan, silahkan Tekan tombol [Enter] untuk melanjutkan..."
echo ""

#cd /root
#wget http://www.webmin.com/jcameron-key.asc
#apt-key add jcameron-key.asc
#sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
#service webmin restart

#rm -f /root/jcameron-key.asc

apt-get -y --force-yes -f install libxml-parser-perl


#rm -R /home/fns/public_html/installation

#cd
#rm -f /root/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

chmod 755 /home/fns/public_html/config
chmod 644 /home/fns/public_html/config/inc.php
chmod 644 /home/fns/public_html/config/route.php

# info
clear
echo "=======================================================" | tee -a log-install.txt
echo "Silahkan login Panel Reseller di http://$MYIP:81" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Auto Script Installer OCS Panels | sshinjector.net"  | tee -a log-install.txt
echo "             (http://www.sshinjector.net/ - 087773091160)           "  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Thanks " | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt
cd ~/

#rm -f /root/ocspanel.sh
