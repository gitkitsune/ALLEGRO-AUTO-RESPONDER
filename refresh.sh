#!/bin/bash
# AUTHOR - Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)

source $1'app.id'

CIDCIS=`echo -n $CID:$CIS | base64`
CEC=`echo $CIDCIS | sed -e 's/ //g'`

TKF=`cat $1'0.auth.tmp' | grep refresh_token: | sed -e 's/refresh_token://'`

curl -X POST \
  'https://allegro.pl/auth/oauth/token?grant_type=refresh_token&refresh_token='$TKF \
  -H 'Authorization: Basic '$CEC \
  | sed -e 's/,/\n/g' | sed -e 's/{//g' | sed -e 's/}//g' | sed -e 's/"//g' > $1'0.auth.tmp'

cat $1'0.auth.tmp' | grep access_token: | sed -e 's/access_token://' > $1'token.var'

echo -n Twój nowy token to: 
cat $1'token.var'
echo
echo "Token został zapisany jako token.var - po upływie ważnośći skorzystaj z ./refresh.sh"
echo "Możesz dodać refresh.sh do cron aby automatycznie odświeżać token raz na trzy miesiące"
echo

exit 0
