#!/bin/bash

# Alright now, introducing The Hostname Roller v 0.1 !
# A script to make your hostname look like a generic Windows or MacBook machine.
# In combination with the Macbot v 0.3 script it provides the ability to spoof
# the trace you leave on a (public) network.
#
#
# NEEDED PREREQUISITES:
# 
# - A wordlist from http://www.outpost9.com/files/wordlists/Given-Names.zip
#   that you need to copy to your /usr/share/dict/ directory for the script 
#   work. 
#
# - The file /usr/share/dict/american-english need to be present, too.
#
# - Also to start system services etc. you need to be root, or sudo the script
#
#
#

### Function that applies the changes provided by the main code block



rollit () {
  ### This part is taken from: 
  ### http://www.blackmoreops.com/2013/12/12/change-hostname-kali-linux/#Change_hostname_randomly_in_each_boot_time
  ##  Thanks for the good work mate.
  ##  I also modified the part about the fully qualified domainname, since it is not necessary if you don't want to run a server.

  cp -n /etc/hosts{,.old}
  idomainname=$(domainname -i)
  fdomainname=$(domainname -f)

  echo $new_hostname > /etc/hostname
  mv /etc/hosts /etc/hosts.old
  echo "127.0.0.1 localhost" > /etc/hosts
  echo "127.0.1.1 $new_hostname" >> /etc/hosts
  echo "$idomainname  $fdomainname    $new_hostname" >> /etc/hosts 
  echo "$idomainname   		       $new_hostname" >> /etc/hosts

  echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
  echo "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts
  echo "ff02::1 ip6-allnodes" >> /etc/hosts
  echo "ff02::2 ip6-allrouters" >> /etc/hosts

  ## I'm not to sure about this part on Ubuntu, since the Author wrote this script for Kali.
  ## So to use this script on Kali, or other Linux distros, you might have to work on that part.


  ## Cleaning up the /etc/NetworkManager/NetworkManager.conf
  service network manager stop
  sed -i  "/^[keyfile]/d" /etc/NetworkManager/NetworkManager.conf
  sed -i  "/^hostname = .*/d" /etc/NetworkManager/NetworkManager.conf
  echo "[keyfile]" >> /etc/NetworkManager/NetworkManager.conf
  echo "hostname = $new_hostname" >> /etc/NetworkManager/NetworkManager.conf
  service network-manager start

  echo "Rolled hostname to: $new_hostname"
  echo
  echo
  exit
}



###
###	Main function
###

clear
echo '******* The Hostname Roller v 0.1 *******'
echo
echo
echo 'Select hostname pattern from following options: '
echo

PS3='Please enter your choice: '
options=("Option 1: Windows" "Option 2: Mac OSX" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Option 1: Windows")
	    echo
            echo "Creating Windows hostname ..."
	    echo

            FILE=/usr/share/dict/american-english
	    WORD=$(sort -R $FILE | head -1)
            SEED=$RANDOM
	    PARTB=$(echo $SEED$WORD | md5sum | cut -c1,2,3,4,5,6,7,8,9,10,11 | tr '[:lower:]' '[:upper:]')
	    new_hostname=$(echo WIN-$PARTB)
	    rollit
	    break
	    ;;


   

        "Option 2: Mac OSX")
            echo
	    echo "Creating MacBook hostname ..."
	    echo

	    FILE=/usr/share/dict/Given-Names
	    NAME=$(sort -R $FILE | head -1)
	    new_hostname=$(echo "$NAME's MacBook")
            rollit
            break
	    ;;



        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done




