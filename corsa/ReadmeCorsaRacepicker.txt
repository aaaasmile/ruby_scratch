== Race Picker
Aggiornamento veloce:
Apri WSL sotto windows con Ubuntu-22.04
igor@MiniToro:/mnt/d/Projects/GitHub/ruby_scratch/corsa$ ruby race_picker.rb

== WSL2 e race_picker
Non mi ricordo più perché in powershell lo script non funziona, ma ci sarà una ragione valida.
In ogni modo su MiniToro uso Ubuntu-22.04.
Non ha funzionato come sopra all'istante. La regione è che un localhost in windows,
per esempio il db postgres, non è accessibile tramite WSL2.
Per questo si usa, non localhost, ma l'IP del resolver. Il quale si legge in WSL2 con:
grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'
Ho notato che questo IP cambia ogni volta che faccio partire la WSL2, per cui lancio
questo comando in ruby ogni volta che mi connetto al db per sapere quale IP devo usare.
Poi va anche configurata una porta nel firewall di windows per ammettere la porta 5432.
1)Launch Windows Defender Firewall with Advanced Security
2)On the left pane select Incoming Rules.
3)On the right pane click on New Rule.
4)For the rule type select Port. Next.
5)Select TCP and Specific local ports. Insert the port 5432
6)Select Allow connection. Next.
7)Check only the Public profile. Next.
8)Enter a name for the rule: WSL postgres.

Poi ho dovuto cambiare anche i seguenti files in C:\Program Files\PostgreSQL\15\data:
postgresql.conf   (=> per avere i messaggi in inglese con lc_messages = 'English_United States.1252')
pg_hba.conf       (=> per avere il collegamento da wsl2 con:  host   all all 172.17.0.0/0   scram-sha-256)

Se nel database l'utente corsa_user non esiste o non ha accesso al db, esso va inserito
usando la powershell:
PS C:\Program Files\PostgreSQL\15\bin> .\createuser.exe --username=postgres --login -P corsa_user
Che vuol dire: ci si collega con l'utente posgres, si crea un nuovo user corsa_user che 
può effettuare dei login. Seguono le passwords (totale 3) per corsa_user e postgres.
Siccome il Database corsadb l'ho creato usando l'utente postgres con restore di un backup,
l'utente corsa_user non può fare nulla. Ho in SQL aggiunto queste 3 linee affinché lo 
script race_picker sia funzionante. Tutte e 3 sono risultate necessarie:
GRANT ALL PRIVILEGES ON DATABASE corsadb TO corsa_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO corsa_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO corsa_user;

== mini-k7

== Restore del db
Con il nuovo sistema mini-k7 mi trovo di nuovo senza db. Ho installato pg su wsl2 e basta. 
Interessante il fatto che se cerco pg tra le app di windows, mi salta fuori pg-admin 4 con 
il simbolo di Linux. Parte senza problemi direttamente da Windows Start. In backround gira 
WSL Ubuntu con l'utente igor@mini-k7. Come faccio ad effettuare il restore del db che ho creato con pgdump?
Per prima cosa creo il db a linea di comando in WSL: 
createdb -T template0 corsadb
Ora vediamo di fare il restore:
cd /mnt/d/Projects/github/ruby_scratch/corsa/backup
Occorre l'utente corsa_user. Come si inserisce?

	createuser --username=igor --login -P  corsa_user
Ora provo il restore

	pg_restore -d corsadb --clean --create ./backup_PG15_06_20221204.sql
Ricevo la solita fila d'errori, ma database corsadb sembra ripristinato.
Poi in pgAdmin ho aperto il database e sulla tabella race ho lanciato il query tool. 
Qui ho copiato le tre righe di GRANT riportate sopra per l'utente corsa_user e l'ho poi lanciato.
A questo punto sono in grado di usare il file SQL per le statistiche, come il numero delle maratone efettuate,
usando il file statistiche.sql che si trova su D:\Projects\github\ruby_scratch\corsa.

== Ruby
Uso rbenv che mi consente di usare una miriade di versioni ruby. Le versioni che ho installato sono visibili con:
rbenv versions
Uso la 3.2.0 con 
rbenv local 3.2.0
Quindi ora ho:
ruby -v
ruby 3.2.0 (2022-12-25 revision a528908271) [x86_64-linux]

Per fare andare ruby_picker.rb ho bisogno dei seguenti gems:
gem install mechanize
gem install pg
gem install log4r
Cambio il file .ruby-version per avere la versione 3.2.0
Ora posso provare con

	ruby race_picker.rb
Nota che le credential del database le ho messe nel file credential.yaml

== Sommario
race_picker.rb:
Script che uso per fare l'aggiornamento del mio db delle gare memorizzate sul sito pentek
In questo modo non devo editare le gare due volte, ma solo sul sito Pentek.

Lo script aggiorna il mio database posgres dove memorizzo i dati delle gare.
Su WSL Ubuntu-22.04 ruby è già configurato con tutti i gem necessari.
Poi però git, se si cambia il codice o questo file, va usato con powershell o vscode.

== Parametri
Ci sono varie opzioni che consentono di fare un check di integrità dei dati. Il check tra il sito pentek e il mio db.
Il comando da usare:
ruby race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}"

cambiando i paramteri è possibile fare gli inserimenti nel db. Comunque senza parametri inserisce solo le nuove corse,
che poi è lo standard da usare.

== Preparazione di Ruby in Ubuntu-22.04
Questa sequenza ha funzionato senza problemi anche con Ubuntu 22.04 che mi ha installato ruby 3.0.
igor@MiniToro:/mnt/d/Projects/GitHub/ruby_scratch/corsa$ ruby -v
ruby 3.0.2p107 (2021-07-07 revision 0db68f0233) [x86_64-linux-gnu]

Quindi si usa in Windows Ubuntu-22.04
Ora mancano tutti i gems che installo facilmente con questa sequenza di comandi:
sudo apt-get install ruby-dev
sudo gem install mechanize
sudo apt-get install libpq-dev
sudo gem install pg
sudo gem install log4r

igors@Laptop-Toni:/mnt/d/Projects/GItHub/ruby_scratch/corsa$ ruby -v
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux-gnu]

== Database
Usa il database postgres locale corsadb. Esso viene aggiornato da WSL.
Il primo DB che ho usato è stato su postgres 9.0, poi su MiniToro sono passato a 15.0.
Per il restore ho usato un backup che mi ha messo degli errori, ma che però alla fine
ha funzionato.

Per provare la connessione ho creato un piccolo progetto in golang che si può 
eseguire in windows o in WSL2 per vedere se la connessione al database pg funziona.

== Inconsistenze
Se si cambia il nome di una gara sul sito "https://www.membersclub.at/ccmc_showprofile.php?unr=9671&show_tacho=1&pass=008"
succede che i nomi nel db non sono più consistenti. Allora si cambiano i dati nel db.
Per prima cosa si trovano i records che non vanno bene:
ruby race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}" 
o per avere un output conciso:
ruby race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}" | grep "is not in the db."
Ora in postgres faccio una query per sapere l'id della corsa che non quadra e la cancello.
Lo script non fa le modifiche, ma solo insert, quindi un record da modificare va prima cancellato nel db e reinserito con loscript 
configurato su insert_missed.

== Problemi SSL
Se ci sono problemi di certificati, per prima cose vedere se curl funziona. 
Poi vedi di aggiornare il sistema e i suoi certificati.
Alla peggio bisogna aggiornare l'Ubuntu in  WSL e ruby.

== OLD

Dal 01.11.2021 WLC legacy non funziona più
La ragione è che 
curl get https://www.membersclub.at/ccmc_showprofile.php?unr=9671&show_tacho=1&pass=008
non funziona più per via dei certificati ca che sono scaduti
Un upgrade del sistema che contiene i certificati non è più possibile, penso per via del long term della versione ubuntu 16.04 scaduto.

Dal 31.03.2019 si usa WLC per l'update.

Comandi  usati in WLC (powershell non va per via di https)
igors@Laptop-Toni:/mnt/d/Projects/GItHub/ruby_scratch/corsa$ ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]


SSL errore
Dal 2019 Pentek usa https e si ha questo errore in windows con powershell:
D:/ruby/ruby_2_3_1/lib/ruby/2.3.0/net/http.rb:933:in `connect_nonblock': SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)

Il problema si risolve con questo comando curl che però ho eseguito in WLC:
sudo curl https://curl.haxx.se/ca/cacert.pem -o "$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')"

Però oi bisogna lanciare lo script usando WLC.
La versione di ruby che ho usato in WLC è la 2.3.1. Qui ho anche installato tutti i gem necessari usando bundle install.
rbenv local 2.3.1
rbenv versions

In ogni modo WLC fa l'update del db di postgres in windows ed è equivalente a powershell.

== OLD OLD OLD
Uso: powershell e 
$env:path = "D:\ruby\ruby_2_3_1\bin"
ruby .\race_picker.rb
