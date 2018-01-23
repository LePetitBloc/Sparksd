#!/bin/bash 

set -x 

#http://stackoverflow.com/questions/34962020/cron-and-crontab-files-not-executed-in-docker
touch /etc/crontab /etc/cron.*/*

# rsyslog
service rsyslog start

# cron
service cron start

./Sparksd -daemon -reindex --datadir=/sparks_data/ --conf=/root/.Sparks/Sparks.conf
/bin/sleep inf
