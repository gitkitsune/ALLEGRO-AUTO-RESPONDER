#!/bin/sh
TOKEN=`cat token.var`

curl -X GET \
'https://api.allegro.pl/sale/disputes?limit=20' \
-H 'Accept: application/vnd.allegro.public.v1+json' \
-H 'Authorization: Bearer '$TOKEN \
| sed -e 's/{"id":"/\n/g' \
| sed -e 's/","subject":/ /g' \
| grep -E "NEW|BUYER_REPLIED" \
| grep ONGOING \
| awk '{print $1}' > dispute.tmp

while [[ -s dispute.tmp ]]
do
ID=`tail -n 1 dispute.tmp`
curl -X POST \
'https://api.allegro.pl/sale/disputes/'$ID'/messages' \
-H 'Accept: application/vnd.allegro.public.v1+json' \
-H 'Authorization: Bearer '$TOKEN \
-H 'Content-Type: application/vnd.allegro.public.v1+json' \
-d '{
  "text": "Dziękujemy za przesłaną wiadomość. Odpowiemy najszybciej jak to możliwe",
  "type": "REGULAR"
}'
sed -i '$d' dispute.tmp
done
