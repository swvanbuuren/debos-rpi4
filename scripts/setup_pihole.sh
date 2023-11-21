#!/bin/sh
# https://discourse.pi-hole.net/t/what-is-setupvars-conf-and-how-do-i-use-it/3533/9
# https://github.com/r-pufky/ansible_pihole/tree/main/templates
# create settings file
mkdir -p /etc/pihole
cat > /etc/pihole/setupVars.conf << EOL
BLOCKING_ENABLED=true
WEBPASSWORD=
ADMIN_EMAIL=
WEBUIBOXEDLAYOUT=boxed
WEBTHEME=default-light
DNSSEC=false
REV_SERVER=true
REV_SERVER_CIDR=192.168.0.0/24
REV_SERVER_TARGET=192.168.0.1
REV_SERVER_DOMAIN=fritz.box
IPV4_ADDRESS=192.168.0.110/24
IPV6_ADDRESS=2a00:6020:43b8:2000:6aa6:936f:20d8:49c2/64
PIHOLE_DNS_3=2a00:6020:100::1
PIHOLE_DNS_4=2a00:6020:200::1
PIHOLE_INTERFACE=eth0
PIHOLE_DNS_1=185.22.44.50
PIHOLE_DNS_2=185.22.45.50
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
CACHE_SIZE=10000
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSMASQ_LISTENING=local
TEMPERATUREUNIT=C
EOL
# install pihole
curl -L https://install.pi-hole.net | bash /dev/stdin --unattended
# create adlists file
cat > /tmp/pihole_adlists.txt << EOL
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts
https://v.firebog.net/hosts/static/w3kbl.txt
https://adaway.org/hosts.txt
https://v.firebog.net/hosts/AdguardDNS.txt
https://v.firebog.net/hosts/Admiral.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
https://v.firebog.net/hosts/Easylist.txt
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts
https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
https://v.firebog.net/hosts/Easyprivacy.txt
https://v.firebog.net/hosts/Prigent-Ads.txt
https://v.firebog.net/hosts/Prigent-Crypto.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt
https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
https://phishing.army/download/phishing_army_blocklist_extended.txt
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt
https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts
https://urlhaus.abuse.ch/downloads/hostfile/
https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser
https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt
EOL
cat /tmp/pihole_adlists.txt | xargs -n1 -I{} sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('{}', 1, 'comment');"
# update gravity
pihole -g
