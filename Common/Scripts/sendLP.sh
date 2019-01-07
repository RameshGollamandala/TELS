#!/bin/sh
cksum $1 > $1.aud
cp $1 /apps/Callidus/tels/datafiles/inbound
cp $1.aud /apps/Callidus/tels/datafiles/inbound
chmod 777 $1.aud
rm -f $1.aud