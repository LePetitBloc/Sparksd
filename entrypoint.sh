#!/bin/bash 

set -x 

./Sparksd -daemon -reindex --datadir=/sparks_data/ --conf=/root/.Sparks/Sparks.conf
/bin/sleep inf
