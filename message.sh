#!/bin/sh
# AUTHOR - Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)

source $1'app.telegram'
TOKEN=`cat $1'token.var'`
BOT=0
SUM=1

curl -X GET \
 'https://api.allegro.pl/messaging/threads?limit=20' \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' > $1'message.tmp'

if grep expired $1'message.tmp' > /dev/null
then
	$1'refresh.sh' $1
else

cat $1'message.tmp' | sed -e 's/{"id":/\n/g' \
 | sed -e 's/]/\n/g' \
 | sed -e 's/"//g' \
 | sed -e 's/{//g' \
 | sed -e 's/}//g' \
 | sed -e 's/,/ /g' \
 | sed -e 's/lastMessageDateTime://g' \
 | sed -e 's/interlocutor:login://g' \
 | grep false > $1'message.tmp'

NEW_DATE=`date -Is | cut -c 1-19`
LAST_TIME=`cat $1'date.var' | cut -c 1-19`

while [[ -s $1'message.tmp' ]]
do
MSG_TIME=`tail -n1 $1'message.tmp' | awk '{print $3}' | cut -c 1-19`
if [[ $MSG_TIME > $LAST_TIME ]];
then
USER=`tail -n1 $1'message.tmp' | awk '{print $4}'`
curl -X POST \
 'https://api.allegro.pl/messaging/messages' \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' \
 -H 'Content-Type: application/vnd.allegro.public.v1+json' \
 -d '{
 "recipient": {
    "login": "'$USER'"
 },
    "text": "Dziękujemy za kontakt. Wiadomośc została zarejestrowana, i udzielimy odpowiedzi najszybciej jak to możliwe"
 }'
BOT=$(( $BOT + $SUM ))
fi
sleep 10
sed -i '$d' $1'message.tmp'
done

echo $NEW_DATE > $1'date.var'

if [ 0 -ge $BOT ];
then
exit 0
else
SEL=`echo $1 | sed -e 's/[[:punct:]]//g'`
PAI=`echo -e "Konto $SEL:\nOdpowiedzi w $BOT czatach"`
# curl -s --data "text=$PAI" --data "chat_id=$CHATID" 'https://api.telegram.org/bot'$BOTID'/sendMessage' > /dev/null
fi
fi

exit 0
