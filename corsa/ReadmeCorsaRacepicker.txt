== Race Picker
Aggiornamento veloce:
Apri WLC sotto windows con Ubuntu-20.04
igors@Laptop-Toni:/mnt/d/Projects/GItHub/ruby_scratch/corsa$ ruby race_picker.rb

== Sommario
race_picker.rb:
Script che uso per fare l'aggiornamento del mio db delle gare memorizzate sul sito pentek
In questo modo non devo editare le gare due volte, ma solo sul sito Pentek.

Lo script aggiorna il mio database posgres dove memorizzo i dati delle gare.
Su WLC Ubuntu-20.04 ruby è già configurato con tutti i gem necessari.
Poi però git, se si cambia il codice o questo file, va usato con powershell o vscode.

== Parametri
Ci sono varie opzioni che consentono di fare un check di integrità dei dati. Il check tra il sito pentek e il mio db.
Il comando da usare:
ruby race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}"

cambiando i paramteri è possibile fare gli inserimenti nel db. Comunque senza parametri inserisce solo le nuove corse,
che poi è lo standard da usare.


== Preparazione di Ruby in Ubuntu-20.04
Quindi si usa in Windows Ubuntu-20.04 che ha installato ruby 2.7. Ora mancano tutti i gems che installo facilmente con questa sequenza di comandi:
sudo apt-get install ruby-dev
sudo gem install mechanize
sudo apt-get install libpq-dev
sudo gem install pg
sudo gem install log4r

igors@Laptop-Toni:/mnt/d/Projects/GItHub/ruby_scratch/corsa$ ruby -v
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux-gnu]

== Database
Usa il database postgres locale corsadb. Esso viene aggiornato da WLC.

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
Se ci sono problemi di certificati, per prima cose vedere se curl funziona. Poi vedi di aggiornare il sistema e i suoi certificati.
Alla peggio bisogna aggiornare l'Ubuntu in  WLC e ruby.

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
