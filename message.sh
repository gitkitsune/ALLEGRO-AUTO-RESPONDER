#!/bin/sh
# AUTHOR - Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)

source $1'app.telegram'
TOKEN=`cat $1'token.var'`
BOT=0
SUM=1
LINES=`wc -l < $1'id.list'`

if [ -z "$2" ]
then
LIMIT=10
else
LIMIT=$2
fi

if [ -z "$3" ]
then
COUNT=100
else
COUNT=$3
fi

#Do momentu osiągnięcia 100 odpowiedzi, automat odpowiada tylko na nieprzeczytane wiadomości. Potem odpowiada nawet na otwarte, ale bez udzielonej odpowiedzi.
if [ $LINES -lt 90 ];
then
GREP='false'
else
GREP='read'
fi

#Pobiera liste wiadomości
curl -X GET \
 'https://api.allegro.pl/messaging/threads?limit='$LIMIT \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' > $1'msg.tmp'

#Sprawdza TOKEN czy nie uległ przedawnieniu, jeśli trzeba to odświeża
if grep expired $1'msg.tmp' > /dev/null
then
	$1'refresh.sh' $1
	exit 0
else

cat $1'msg.tmp' | sed -e 's/{"id":/\n/g' \
 | sed -e 's/]/\n/g' \
 | sed -e 's/"//g' \
 | sed -e 's/{//g' \
 | sed -e 's/}//g' \
 | sed -e 's/,/ /g' \
 | sed -e 's/lastMessageDateTime://g' \
 | sed -e 's/interlocutor:login://g' \
 | sed 1d | sed '$d' \
 | grep 'read' > $1'msg.tmp'


#Sprawdza wiadomości, i jesli brak odpowiedzi to jej udziela.
while [[ -s $1'msg.tmp' ]]
do
THDID=`head -n1 $1'msg.tmp' | awk '{print $1}'`
LOGIN=`head -n1 $1'msg.tmp' | awk '{print $4}'`
THD=`curl -X GET \
 'https://api.allegro.pl/messaging/threads/'$THDID'/messages' \
 -H 'Authorization: Bearer '$TOKEN \
 -H 'Accept: application/vnd.allegro.public.v1+json' | sed -e 's/"//g' -e 's/thread:{id://g' -e 's/\[//g' -e 's/\]//g' -e 's/[{}]//g' -e 's/messages://' -e 's/,/ /g' -e 's/author:login://g'`

echo $THD | sed -e 's/id:/\n/g' | sed '1d' | head -n1 | grep $LOGIN > $1'thd.tmp'

TEXT=`echo $THD | sed -e 's/id:/\n/g' | sed '1d' | head -n1 | sed -e 's/text:/\n/' | sed -e 's/subject:/\n/' | sed '1d' | sed '$d' | sed -e 's/ //g'`
MSGID=`cat $1'thd.tmp' | awk '{print $1}'`

#Sprawdza czy udzielona została odpowiedź o takiej treści dla tego użytkownika
if ! grep -e $LOGIN $1'id.list' | awk '{$1=""; $2=""; $3=""; print $0}' | sed -e 's/ //g' | grep $TEXT >> /dev/null
then

if [ -n "$MSGID" ]
then

if ! grep $MSGID $1'id.list' > /dev/null
then

BOT=$(( $BOT + $SUM ))
DATE=`date -Is`
echo $MSGID $LOGIN $DATE $TEXT >> $1'id.list'

#Odpowiada na wiadomość
curl -X POST \
'https://api.allegro.pl/messaging/messages' \
-H 'Authorization: Bearer '$TOKEN \
-H 'Accept: application/vnd.allegro.public.v1+json' \
 -H 'Content-Type: application/vnd.allegro.public.v1+json' \
 -d '{
 "recipient": {
    "login": "'$LOGIN'"
 },
    "text": "Dziękujemy za kontakt. Wiadomość została zarejestrowana. Odpowiedzi udzielimy najszybciej jak to możliwe"
 }'
sed -i '1d' $1'msg.tmp'
else
sed -i '1d' $1'msg.tmp'
fi

else
sed -i '1d' $1'msg.tmp'
fi

else
sed -i '1d' $1'msg.tmp'
echo POMIJAM-$MSGID $LOGIN $DATE $TEXT >> $1'id.list'
fi

sleep 2

done

#Wysyła powiadomienie na TELEGRAM
if [ 0 -ge $BOT ];
then
exit 0
else
SEL=`echo $1 | sed -e 's/[[:punct:]]//g'`
PAI=`echo -e "Konto $SEL:\nNowych wiadomości prywatnych: $BOT"`
curl -s --data "text=$PAI" --data "chat_id=$CHATID" 'https://api.telegram.org/bot'$BOTID'/sendMessage' > /dev/null
fi

fi

while [ $LINES -gt $COUNT ]
do
sed -i '1d' $1'id.list'
LINES=`wc -l < $1'id.list'`
done


exit 0
