#!/bin/bash

heroku container:login


ADDR=$(cut -d " " -f 2 <<< $(cut -d "=" -f 2 <<< $(grep "db.addr = "     conf/artanis.conf)))
USER=$(cut -d " " -f 2 <<< $(cut -d "=" -f 2 <<< $(grep "db.username = " conf/artanis.conf)))
PASS=$(cut -d " " -f 2 <<< $(cut -d "=" -f 2 <<< $(grep "db.passwd = "   conf/artanis.conf)))
NAME=$(cut -d " " -f 2 <<< $(cut -d "=" -f 2 <<< $(grep "db.name = "     conf/artanis.conf)))

EMAIL_ADDR=`cat .env | grep ADDRESS | cut -d "=" -f 2`
EMAIL_PASS=`cat .env | grep PASSWOR | cut -d "=" -f 2`



sed -i -e 's/db.addr = '"$ADDR"'/db.addr = '"$SWANYE_DEPLOY_ADDR"'/g'         conf/artanis.conf
sed -i -e 's/db.username = '"$USER"'/db.username = '"$SWANYE_DEPLOY_USER"'/g' conf/artanis.conf
sed -i -e 's/db.passwd = '"$PASS"'/db.passwd = '"$SWANYE_DEPLOY_PASS"'/g'     conf/artanis.conf
sed -i -e 's/db.name = '"$NAME"'/db.name = '"$SWANYE_DEPLOY_NAME"'/g'         conf/artanis.conf

sed -i -e 's/"from           \$EMAIL_ADDRESS"/"from           '"$EMAIL_ADDR"'"/g'  Dockerfile
sed -i -e 's/"user           \$EMAIL_ADDRESS"/"user           '"$EMAIL_ADDR"'"/g'  Dockerfile
sed -i -e 's/"password       \$EMAIL_PASSWORD"/"password       '"$EMAIL_PASS"'"/g' Dockerfile

echo -e "\n\nCOPY entrypoint.sh /entrypoint.sh\nRUN chmod 755 /entrypoint.sh\n\nENTRYPOINT [\"/entrypoint.sh\"]\n" >> Dockerfile
echo -n "CMD [\"/usr/local/bin/art\", \"work\"]"                                                                   >> Dockerfile



heroku container:push web --app swanye



sed -i -e 's/db.addr = '"$SWANYE_DEPLOY_ADDR"'/db.addr = '"$ADDR"'/g'         conf/artanis.conf
sed -i -e 's/db.username = '"$SWANYE_DEPLOY_USER"'/db.username = '"$USER"'/g' conf/artanis.conf
sed -i -e 's/db.passwd = '"$SWANYE_DEPLOY_PASS"'/db.passwd = '"$PASS"'/g'     conf/artanis.conf
sed -i -e 's/db.name = '"$SWANYE_DEPLOY_NAME"'/db.name = '"$NAME"'/g'         conf/artanis.conf

sed -i -e 's/"from           '"$EMAIL_ADDR"'"/"from           \$EMAIL_ADDRESS"/g'  Dockerfile
sed -i -e 's/"user           '"$EMAIL_ADDR"'"/"user           \$EMAIL_ADDRESS"/g'  Dockerfile
sed -i -e 's/"password       '"$EMAIL_PASS"'"/"password       \$EMAIL_PASSWORD"/g' Dockerfile

head -n -7 Dockerfile > temp.txt; mv temp.txt Dockerfile
perl -pi -e 'chomp if eof' Dockerfile
