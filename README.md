Skrypty automatycznych odpowiedzi na pytania i dyskusje na platformie allegro.pl - Twórca Jarosław Strauchmann (jaroslaw.strauchmann@gmail.com)

Wyrażam zgodę na powielanie, modyfikowanie i użytkowanie bez żadnych opłat (prosze tylko o e-mail z informacją że korzystasz). Nie wyrażam zgody wykorzystywanie jakiejkolwiek części w projektach sprzedawanych komerycjnie.

Skrypty działają w systemach UNIX (testowane na linux), tak więc bez problemu można je uruchomić na większości planów hostingowych, na routerach (w których można dodać własne aplikacje do CRON - polecam hack na OpenWRT).

Zasada działania:
1. W pierwszej kolejności należy zarejestrować aplikację w sekcji dla developerów allegro api. Aplikacja wymaga potwierdzenia tożsamości na poziomie urządzenia - device
2. Następnie po otrzymaniu danych autoryzacyjnych aplikacji, należy przeprowadzić autoryzacje aplikacji na koncie użytkownika. Dane aplikacji należy wpisać do app.id i uruchomić ./auth.sh skrypt odpyta allegro i wyświetli wygenerowany link na który należy wejść, i logując się na konto allegro potwierdzić powiązanie aplikacji.
3. W pliku date.var wpisać datę i godzinę od której chcemy aby skrypt generował automatyczne odpowiedzi (format ISO 8601 'date -uIs')
4. Pozostaje jeszcze dodać do zadań CRON nasze skrypty. 

*/30 * * * * dispute.sh FOLDER/ #Działanie co 30 minut (zmienić wedle uznania)
*/30 * * * * message.sh FOLDER/ #Działanie co 30 minut (zmienić wedle uznania)

UWAGA WAŻNE !!! CRON uruchamia skrypt domyślnie w katalogu użytkownika, i tam też wylądują wszystkie zmienne. Dlatego zalecam aby utworzyć w katalogu domowym folder z nazwą konta ALLEGRO, i wpisać ten folder w formacie "FOLDER/" za wywołaniem komendy w CRON. Wszystkie zmienne wylądują w folderze, bez problemu powinien też działać system automatycznego przedłużania tokena.

Skrypty odpytują serwer allegro w określonych przec Ciebie odstępach czasu (cron), i jeśli znajdują nowe odpowiedzi w dyskusji to wysyłają sformatowaną odpowiedź. Dla wiadomości prywatnych, przy każdym odpytywaniu skrypt zapisuje datę ostatniego uruchomienia, i odpowiada tylko na wiadomości nowsze niż ostatnia zapisana data.

UWAGA !!! Jeśli korzystasz z komunikatora TELEGRAM - możesz zarejestrować nowego bota (po prostu znajdź użytkownika @BotFather i go poproś o bota - otrzymasz TOKEN identyfikacyjny). Następnie stwórz grupę, i dodaj do niej bota. Po wysłaniu dowolnej wiadomści w grupie, wejdź na stronę:

https://api.telegram.org/bot<TOKEN TWOJEGO BOTA>/getUpdates

Tam znajdziesz "chat" i zaraz za nim ID. Token bota, oraz chat ID wpisz w pliku konfiguracyjnym app.telegram

Wyedytuj skrypt message.sh oraz dispute.sh usuwająs hash "#" z linii:
# curl -s --data "text=$PAI" --data "chat_id=$CHATID" 'https://api.telegram.org/bot'$BOTID'/sendMessage' > /dev/null
