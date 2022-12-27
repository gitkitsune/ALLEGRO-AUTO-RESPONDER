#!/bin/sh
TOKEN=`cat token.var`

curl -X GET \
 'https://api.allegro.pl/messaging/threads?limit=20' \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' \
 | sed -e 's/{"id":/\n/g' \
 | sed -e 's/"//g' \
 | sed -e 's/{//g' \
 | sed -e 's/}//g' \
 | sed -e 's/,/ /g' \
 | sed -e 's/lastMessageDateTime://g' \
 | sed -e 's/interlocutor:login://g' \
 | grep false > message.tmp

NEW_DATE=`date -Is | cut -c 1-19`
LAST_TIME=`cat date.var | cut -c 1-19`

while [[ -s message.tmp ]]
do
MSG_TIME=`tail -n1 message.tmp | awk '{print $3}' | cut -c 1-19`
if [[ $MSG_TIME > $LAST_TIME ]];
then
USER=`tail -n1 message.tmp | awk '{print $4}'`
curl -X POST \
 'https://api.allegro.pl/messaging/messages' \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' \
 -H 'Content-Type: application/vnd.allegro.public.v1+json' \
 -d '{
 "recipient": {
    "login": "'$USER'"
 },
    "text": "Dziękujemy za przesłaną wiadomość. Odpowiemy najszybciej jak to możliwe"
 }'

fi
sed -i '$d' message.tmp
sleep 10
done

echo $NEW_DATE > date.var
