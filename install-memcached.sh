#! /bin/bash
#
# Script to install an memcached





# APT

# env var pour que APT sache qu'on ne va pas lui répondre
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
apt -y update
apt-get -y dist-upgrade
apt-get -y install --no-install-recommends memcached


#### Y'a rien a faire dans la conf, tous est dans les params de lancement (les 2 ENV)



# Nettoyage du cache APT 
apt-get clean
apt-get autoclean

# Nettoyage liste APT (90 Mo) et cache archives (idem)
# Il faudra faire un apt-get update avant prochain usage
rm -rf /var/lib/apt/lists/* 2>/dev/null
rm -rf /var/cache/apt/*pkgcache.bin 2>/dev/null


# Clean des conneries avant de clore l'image
rm -rf /tmp/* /var/tmp/* 2> /dev/null
find /var/log -type f -delete 2> /dev/null

