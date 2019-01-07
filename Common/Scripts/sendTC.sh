#!/bin/bash
cksum $1 > $1.aud
cp $1 /apps/Callidus/tels/datafiles/toapp
cp $1.aud /apps/Callidus/tels/datafiles/toapp
chmod 777 $1.aud
rm -f $1.aud