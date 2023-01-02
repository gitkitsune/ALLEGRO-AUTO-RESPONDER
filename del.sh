#!/bin/sh
# AUTHOR - Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)

source $1'app.telegram'
TOKEN=`cat $1'token.var'`
BOT=0
SUM=1
LINES=`wc -l < $1'id.list'`

#Pobiera liste wiadomości
curl -X GET \
 'https://api.allegro.pl/messaging/threads?limit=20' \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' > $1'del.tmp'

cat $1'del.tmp' | sed -e 's/{"id":/\n/g' \
 | sed -e 's/]/\n/g' \
 | sed -e 's/"//g' \
 | sed -e 's/{//g' \
 | sed -e 's/}//g' \
 | sed -e 's/,/ /g' \
 | sed -e 's/lastMessageDateTime://g' \
 | sed -e 's/interlocutor:login://g' \
 | sed 1d | sed '$d' | grep $2 > $1'del.tmp'

THDID=`head -n1 $1'del.tmp' | awk '{print $1}'`
THD=`curl -X GET \
 'https://api.allegro.pl/messaging/threads/'$THDID'/messages' \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' | sed -e 's/"//g' -e 's/thread:{id://g' -e 's/\[//g' -e 's/\]//g' -e 's/[{}]//g' -e 's/messages://' -e 's/,/ /g' -e 's/author:login://g'`

echo $THD | sed -e 's/id:/\n/g' | sed '1d' > $1'del1.tmp'

while [[ -s $1'del1.tmp' ]]
do
MSGID=`cat $1'del1.tmp' | head -n1 | awk '{print $1}'`
echo $MSGID
curl -X DELETE \
'https://api.allegro.pl/messaging/messages/'$MSGID \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' 
sed -i '1d' $1'del1.tmp'
done

rm $1'del.tmp'
rm $1'del1.tmp'

exit 0