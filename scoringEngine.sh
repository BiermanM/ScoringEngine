#!/bin/bash
clear
if [[ $EUID -ne 0 ]]
then
  echo Score must be run as root.
  exit
fi

function check_if_papyrus_exists()
{
	if getent passwd papyrus > /dev/null 2>&1
	then
		up1="User Papyrus has been added."
	else
		up1="***"
	fi
}

function check_if_ashore_exists()
{
	if getent passwd ashore > /dev/null 2>&1
	then
		up2="User Ashore has been added."
	else
		up2="***"
	fi
}

function check_if_mettaton_exists()
{
	if getent passwd mettaton > /dev/null 2>&1
	then
		up3="User Mettaton has been added."
	else
		up3="***"
	fi
}

function check_if_flowey_exists()
{
	if getent passwd flowey > /dev/null 2>&1
	then
		up4="***"
	else
		up4="User Flowey has been removed."
	fi
}

function check_if_chara_exists()
{
	if getent passwd chara > /dev/null 2>&1
	then
		up5="***"
	else
		up5="User Chara has been removed."
	fi
}

function check_if_sans_is_admin()
{
	if groups sans | grep -q -w sudo > /dev/null 2>&1
	then
		up6="User Sans has become an administrator."
	else 
		up6="***"
	fi
}

function check_if_alphys_is_admin()
{
	if groups alphys | grep -q -w sudo > /dev/null 2>&1
	then
		up7="User Alphys has become an administrator."
	else 
		up7="***"
	fi
}

function check_if_undyne_is_admin()
{
	if groups undyne | grep -q -w sudo > /dev/null 2>&1
	then
		up8="***"
	else 
		up8="User Undyne has become a standard user."
	fi
}

function check_if_all_users_have_new_passwords()
{
	day=$(date +%d)
	nextDay=$(expr $(date +%d) + 1)
	month=$(date +%m)
	year=$(date +%Y)

	usersList=$(awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd)
	users=($usersList)
	usersLength=${#users[@]}
	allUpdated=true
	count=0

	while [ $allUpdated == true ] && [ $count -lt $usersLength ]
	do
		pwInfo=$(passwd -S ${users[${count}]})
		updatedToday="${users[${count}]} P $month/$nextDay/$year"
		updatedNextDay="${users[${count}]} P $month/$day/$year"
		if [[ "$pwInfo" =~ "$updatedToday" ]] || [[ "$pwInfo" =~ "$updatedNextDay" ]]
		then
			allUpdated=true
		else
			allUpdated=false
		fi
		let "count += 1"
	done
	
	if [ $allUpdated == true]
	then
		up9="The passwords for all users have been updated."
	else
		up9="***"
	fi
}

function check_if_root_account_is_locked()
{
	if [[ $(passwd -S root) =~ "root L" ]]
	then
		acs1="Root account has been locked."
		m3="Root password has been locked."
	else
		acs1="***"
		m3="***"
	fi
}

function check_file_permissions_for_shadow()
{
	if [ $(stat -c "%a" /etc/shadow) -le "644" ]
	then
		acs2="Correct file permissions for shadow have been set."
	else
		acs2="***"
	fi
}

function check_file_permissions_for_bashrc()
{
	if [ $(stat -c "%a" ~/.bashrc) -le "644" ]
	then
		acs3="Correct file permissions for bashrc have been set."
	else
		acs3="***"
	fi
}

function check_apt_repos()
{
	fullSourcesList="deb http://us.archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse\ndeb-src http://us.archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse\ndeb http://us.archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse\ndeb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse\ndeb http://us.archive.ubuntu.com/ubuntu/ trusty-proposed main restricted universe multiverse\ndeb-src http://us.archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse\ndeb-src http://us.archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse\ndeb-src http://us.archive.ubuntu.com/ubuntu/ trusty-proposed main restricted universe multiverse"
	if grep -q "$fullSourcesList" "/etc/apt/sources.list"
	then
		acs4="Apt Repositories have been correctly configured."
	else
		acs4="***"
	fi
}

function forensics_q1()
{
	if grep -q "cowsay" "Desktop/Forensics Question 1.txt"
	then
		fq1="Forensics Question #1 is correct."
	else
		fq1="***"
	fi
}

function forensics_q2()
{
	if grep -q "lsb_release -r" "Desktop/Forensics Question 2.txt"
	then
		fq2="Forensics Question #2 is correct."
	else
		fq2="***"
	fi
}

function forensics_q3()
{
	if grep -q "/home/alphys/Videos/trailer.mp4" "Desktop/Forensics Question 3.txt"
	then
		fq3="Forensics Question #3 is correct."
	else
		fq3="***"
	fi
}

function check_crontab()
{
	if grep -q "nc -q -1 -P ANONYMOUS 10.0.1.2 7700" "/etc/crontab"
	then
		mal1="***"
	else
		mal1="Netcat has been removed from crontab."
	fi
}

function video_file()
{
	if [ -e /home/alphys/Videos/trailer.mp4 ]
	then
		pvf1="***"
	else
		pvf1="The video file has been removed from the home directory of Alphys."
	fi
}

function photo_zip_file()
{
	if [ -e /home/flowey/Pictures/"check this out".zip ]
	then
		pvf2="***"
	else
		pvf2="The picture files have been removed from the home directory of Flowey."
	fi
}

function web_server_files()
{
	if [ -e /var/www/index.php ] || [ -e /var/www/register.php ] || [ -e /var/www/test.php ]
	then
		pvf3="***"
	else
		pvf3="All web server files have been removed from the system."
	fi
}

function check_for_samba()
{
	if [[ $(dpkg -l) =~ "ii  samba                                         2:4.1.17+dfsg-4ubuntu3.1                   amd64        SMB/CIFS file, print, and login server for Unix" ]]
	then
		pvs1="***"
	else
		pvs1="Samba services have been removed."
	fi
}

function check_for_ssh()
{
	if [[ $(dpkg -l) =~ "openssh-server" ]]
	then
		pvs2="***"
	else
		pvs2="SSH services have been removed."
	fi
}

function check_fully_updated()
{
	if [ $(/usr/lib/update-notifier/apt-check 2>&1 | cut -d ';' -f 1) == 0 ] && $(/usr/lib/update-notifier/apt-check 2>&1 | cut -d ';' -f 2) == 0 ]
	then
		uos1="Linux kernel has been updated."
		uos2="Bash has been updated."
	else
		uos1="***"
		uos2="***"
	fi
}

function clamav_updated()
{
	if [ $(freshclam --version) == "ClamAV 0.99.0" ] || [ $(freshclam --version) == "ClamAV 0.99" ]
	then
		uo1="ClamAV has been updated."
	else
		uo1="***"
	fi
}

function ufw_enabled()
{
	if [[ $(ufw status) == "Status: inactive" ]]
	then
		f1="***"
	else
		f1="UFW has been enabled."
	fi
}

function ftp_firewall_enabled()
{
	if [[ $(ufw status) =~ "21/tcp                     ALLOW       Anywhere" ]] && [[ $(ufw status) =~ "21/tcp (v6)                ALLOW       Anywhere (v6)" ]]
	then
		f1="The FTP port has been allowed on the firewall."
	else
		f2="***"
	fi
}

function printer_firewall_enabled()
{
	if [[ $(ufw status) =~ "515/tcp                    ALLOW       Anywhere" ]] && [[ $(ufw status) =~ "515/tcp (v6)               ALLOW       Anywhere (v6)" ]]
	then
		f3="The Printer port has been allowed on the firewall."
	else
		f3="***"
	fi
}

function ipp_firewall_enabled()
{
	if [[ $(ufw status) =~ "631                        ALLOW       Anywhere" ]] && [[ $(ufw status) =~ "631 (v6)                   ALLOW       Anywhere (v6)" ]]
	then
		f4="The IPP port has been allowed on the firewall."
	else
		f4="***"
	fi
}

function check_for_bind9()
{
	if [[ $(dpkg -l) =~ "ii  bind9                                         1:9.9.5.dfsg-11ubuntu1.2                   amd64        Internet Domain Name Server" ]]
	then
		is1="***"
	else
		is1="Bind9 services have been removed."
	fi
}

function check_for_aircrack_ng()
{
	if [[ $(dpkg -l) =~ "ii  aircrack-ng                                   1:1.2-0~beta3-4                            amd64        wireless WEP/WPA cracking utilities" ]]
	then
		is2="***"
	else
		is2="Aircrack-NG services have been removed."
	fi
}

function check_for_zeitgeist()
{
	if [[ $(dpkg -l) =~ "ii  zeitgeist                                     0.9.16-0ubuntu3~gcc5.1                     all          event logging framework" ]]
	then
		is3="***"
	else
		is3="Zeitgeist services have been removed."
	fi
}

function rogue_alias()
{
	if grep -q "alias help" "~/.bashrc"
	then
		m1="***"
	else
		m1="All rogue alias have been removed."
	fi
}

function check_auditd()
{
	if [[ $(dpkg -l) =~ "auditd" ]] && [[ $(autidctl -s) =~ "enabled 1" ]]
	then
		m2="AuditD has been installed and auditing has been enabled."
	else
		m2="***"
	fi
}

function login_defs()
{
	if grep -q "PASS_MAX_DAYS	30" "/etc/login.defs" && grep -q "PASS_MIN_DAYS	3" "/etc/login.defs" && grep -q "PASS_WARN_AGE	7" "/etc/login.defs"
	then
		pp1="Password policies have been set with login.defs."
	else
		pp1="***"
	fi
}

function check_for_clamav()
{
	if [[ $(dpkg -l) =~ "clamav" ]]
	then
		pcs1="ClamAV services have been installed."
	else
		pcs1="***"
	fi
}

function check_for_vsftpd()
{
	if [[ $(dpkg -l) =~ "vsftpd" ]]
	then
		pcs2="FTP services have been installed."
	else
		pcs2="***"
	fi
}

function check_for_printing()
{
	if [[ $(dpkg -l) =~ "ii  cups                                          2.1.0-4ubuntu3                             amd64        Common UNIX Printing System(tm) - PPD/driver support, web interface" ]]
	then
		pcs3="Printing services have been installed."
	else
		pcs3="***"
	fi
}

check_if_papyrus_exists 2> /dev/null
check_if_ashore_exists 2> /dev/null
check_if_mettaton_exists 2> /dev/null
check_if_flowey_exists 2> /dev/null
check_if_chara_exists 2> /dev/null
check_if_sans_is_admin 2> /dev/null
check_if_alphys_is_admin 2> /dev/null
check_if_undyne_is_admin 2> /dev/null
check_if_all_users_have_new_passwords 2> /dev/null
check_if_root_account_is_locked 2> /dev/null
check_file_permissions_for_shadow 2> /dev/null
check_file_permissions_for_bashrc 2> /dev/null
check_apt_repos 2> /dev/null
forensics_q1 2> /dev/null
forensics_q2 2> /dev/null
forensics_q3 2> /dev/null
check_crontab 2> /dev/null
video_file 2> /dev/null
photo_zip_file 2> /dev/null
web_server_files 2> /dev/null
check_for_samba 2> /dev/null
check_for_ssh 2> /dev/null
check_fully_updated 2> /dev/null
clamav_updated 2> /dev/null
ufw_enabled 2> /dev/null
ftp_firewall_enabled 2> /dev/null
printer_firewall_enabled 2> /dev/null
ipp_firewall_enabled 2> /dev/null
check_for_bind9 2> /dev/null
check_for_aircrack_ng 2> /dev/null
check_for_zeitgeist 2> /dev/null
rogue_alias 2> /dev/null
check_auditd 2> /dev/null
login_defs 2> /dev/null
check_for_clamav 2> /dev/null
check_for_vsftpd 2> /dev/null
check_for_printing 2> /dev/null

echo "User Policy (9)
1. $up1
2. $up2
3. $up3
4. $up4
5. $up5
6. $up6
7. $up7
8. $up8
9. $up9
Access Control & Settings (4)
1. $acs1
2. $acs2
3. $acs3
4. $acs4
Forensics Questions (3)
1. $fq1
2. $fq2
3. $fq3
Malware (1)
1. $mal1
Policy Violation: Files (3)
1. $pvf1
2. $pvf2
3. $pvf3
Policy Violation: Services (2) 
1. $pvs1
2. $pvs2
Updates: Operating System (2)
1. $uos1
2. $uos2
Updates: Other (1)
1. $uo1
Firewall (4)
1. $f1
2. $f2
3. $f3
4. $f4
Insecure Services (3)
1. $is1
2. $is2
3. $is3
Miscellaneous (3)
1. $m1
2. $m2
3. $m3
Password Policy (1)
1. $pp1
Policy Compliance: Software (3)
1. $pcs1
2. $pcs2
3. $pcs3"