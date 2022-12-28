#!/bin/bash
# AUTHOR - Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)

source ./app.id

CIDCIS=`echo -n $CID:$CIS | base64`
CEC=`echo $CIDCIS | sed -e 's/ //g'`

curl -X POST \
  'https://allegro.pl/auth/oauth/device?client_id='$CID \
  -H 'Authorization: Basic '$CEC \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  | sed -e 's/,/\n/g' | sed -e 's/{//g' | sed -e 's/}//g' | sed -e 's/"//g' > 1.auth.tmp

echo
cat 1.auth.tmp | grep complete | sed -e 's/verification_uri_complete:/Autoryzuj aplikację pod adresem: /'
echo
echo -n 'Po uzyskaniu autoryzacji wciśnij dowolny klawisz.'
read -s -n1 key
echo

DEC=`cat 1.auth.tmp | grep device_code: | sed -e 's/device_code://'`
curl -X POST \
'https://allegro.pl/auth/oauth/token?grant_type=urn:ietf:params:oauth:grant-type:device_code&device_code='$DEC \
  -H 'Authorization: Basic '$CEC \
  | sed -e 's/,/\n/g' | sed -e 's/{//g' | sed -e 's/}//g' | sed -e 's/"//g' > 2.auth.tmp

TKF=`cat 2.auth.tmp | grep refresh_token: | sed -e 's/refresh_token://'`

curl -X POST \
  'https://allegro.pl/auth/oauth/token?grant_type=refresh_token&refresh_token='$TKF \
  -H 'Authorization: Basic '$CEC \
  | sed -e 's/,/\n/g' | sed -e 's/{//g' | sed -e 's/}//g' | sed -e 's/"//g' > 0.auth.tmp

cat 0.auth.tmp | grep access_token: | sed -e 's/access_token://' > token.var

echo
echo "Token został zapisany jako token.var - po upływie ważnośći skorzystaj z ./refresh.sh"
echo "Możesz dodać refresh.sh do cron aby automatycznie odświeżać token raz na trzy miesiące"
echo

exit 0
