# ALLEGRO-AUTO-RESPONDER

Proste skrypty ułatwiające pracę sprzedawców ALLEGRO - odpytują serwer ALLEGRO w temacie nowych wiadomości prywatnych i dyskusji, po czym jeśli takowe są wysyłają automatyczne odpowiedzi z zapewnieniem kontaktu w późnijszym terminie.

Zasada działania. W pierwszej kolejności należy zarejestrować aplikację w sekcji dla developeróœ allegro api. Następnie po otrzymaniu danych autoryzacyjnych aplikacji

Skrypty usprawniające odpowiedzi do klientów w platformie ALLEGRO

1. Zarejestrować aplikację w ALLEGRO API - potwierdzenie tożsamości na urządzenie - device
2. Wpisać dane tożsamości do pliku "app.id"
3. Uruchomiść skrypt ./auth.sh - wejść na adres wygenerowany przez skrypt i potwierdzić powiążanie aplikacji, następnie wrócić do skryptu i potwierdzić dalsze działanie
4. W pliku date.var wpisać datę i godzinę od której skrypt ma generować automatyczne odpowiedzi (format Is)
5. Dodać do zadań CRON:
* * * */2 * refresh.sh - co 2 miesiące (maksymalny czas powiązania 3 miesiące)
*/30 * * * * dispute.sh - co 30 minut (wedle uznania)
*/30 * * * * message.sh - co 30 minut (wedle uznania)

Jeśli masz więcej kont, po prostu zrób osobny katalog dla każdego konta.

To wszystko...

Stworzone przez Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)
Wyrażam zgodę na powielanie, modyfikowanie i użytkowanie bez żadnych opłat - ale miło jeśli się odezwiesz że korzystasz.
Nie wyrażam zgody na wykorzystywanie jakiejkolwiek części w projektach sprzedawanych komercyjnie.
