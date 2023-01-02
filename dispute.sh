#!/bin/sh
# AUTHOR - Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)

source $1'app.telegram'
TOKEN=`cat $1'token.var'`
BOT=0
SUM=1

curl -X GET \
'https://api.allegro.pl/sale/disputes?limit=20' \
-H 'Accept: application/vnd.allegro.public.v1+json' \
-H 'Authorization: Bearer '$TOKEN > $1'dispute.tmp'

if grep expired $1'dispute.tmp'
then
	echo "TOKEN PROBLEM"
	$1'refresh.sh' $1
else

cat $1'dispute.tmp' > $1'dispute.test.tmp'
cat $1'dispute.tmp' | sed -e 's/{"id":"/\n/g' \
| sed -e 's/","subject":/ /g' \
| grep -E "NEW|BUYER_REPLIED" \
| grep ONGOING \
| awk '{print $1}' > $1'dispute.tmp'


while [[ -s $1'dispute.tmp' ]]
do
ID=`tail -n 1 $1'dispute.tmp'`
curl -X POST \
'https://api.allegro.pl/sale/disputes/'$ID'/messages' \
-H 'Accept: application/vnd.allegro.public.v1+json' \
-H 'Authorization: Bearer '$TOKEN \
-H 'Content-Type: application/vnd.allegro.public.v1+json' \
-d '{
  "text": "Dziękujemy za kontakt. Wiadomośc została zarejestrowana, i udzielimy odpowiedzi najszybciej jak to możliwe",
  "type": "REGULAR"
}'
BOT=$(( $BOT + $SUM ))
sed -i '$d' $1'dispute.tmp'
sleep 10
done

if [ 0 -ge $BOT ];
then
exit 0
else
SEL=`echo $1 | sed -e 's/[[:punct:]]//g'`
PAI=`echo -e "Konto $SEL:\nNowych zdarzeń w dyskusjach: $BOT"`
curl -s --data "text=$PAI" --data "chat_id=$CHATID" 'https://api.telegram.org/bot'$BOTID'/sendMessage' > /dev/null
fi
fi

exit 0
