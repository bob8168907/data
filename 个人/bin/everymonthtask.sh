#!/bin/bash
vsfPath=/home/vsf
importurl="${vsfPath}/project/demodb"
now=$(date +%Y%m)
file=$importurl/${now}.sql
./importdb.sh $file
