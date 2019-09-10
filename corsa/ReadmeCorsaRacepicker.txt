Dal 31.03.2019 si usa WLC per l'update.

== Comandi  usati in WLC (pwoershell non va per via di https)
igors@Laptop-Toni:/mnt/d/Projects/GItHub/ruby_scratch/corsa$ ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]

igors@Laptop-Toni:/mnt/d/Projects/GItHub/ruby_scratch/corsa$ ruby race_picker.rb


== Parametri
Ci sono varie opzioni che consentono di fare un check di integrità dei dati. Il check tra il sito pentek e il mio db.
Il comando da usare:
ruby .\race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}"

cambiando i paramteri è possibile fare gli inserimenti nel db. Comunque senza parametri inserisce solo le nuove corse,
che poi è lo standard da usare.


== Sommario
race_picker.rb:
Script che uso per fare l'aggiornamento del mio db delle gare memorizzate sul sito pentek
In questo modo non devo editare le gare due volte, ma solo sul sito Pentek.

Lo script aggiorna il mio database posgres dove memorizzo i dati delle gare.
Su WLC ruby è già configurato con rbenv. Però la versione dove sono installati i vari gems è la 2.3.1
Poi però git, se si cambia il codice o questo file, va usato con powershell.

== SSL errore
Dal 2019 Pentek usa https e si ha questo errore in windows con powershell:
D:/ruby/ruby_2_3_1/lib/ruby/2.3.0/net/http.rb:933:in `connect_nonblock': SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)

Il problema si risolve con questo comando curl che però ho eseguito in WLC:
sudo curl https://curl.haxx.se/ca/cacert.pem -o "$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')"

Però oi bisogna lanciare lo script usando WLC.
La versione di ruby che ho usato in WLC è la 2.3.1. Qui ho anche installato tutti i gem necessari usando bundle install.
rbenv local 2.3.1
rbenv versions

In ogni modo WLC fa l'update del db di postgres in windows ed è equivalente a powershell.


== Database
Usa il database postgres locale corsadb. Esso viene aggiornato da WLC e nel passato da powershell.

== Inconsistenze
Se si cambia il nome di una gara sul sito "https://www.membersclub.at/ccmc_showprofile.php?unr=9671&show_tacho=1&pass=008"
succede che i nomi nel db non sono più consistenti. Allora si cambiano i dati nel db.
Per prima cosa si trovano i records che non vanno bene:
ruby race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}" 
o per avere un otput conciso:
ruby race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}" | grep "is not in the db."
Ora in postgres faccio una quesri per sapere l'id della corsa che non quadra e lo cancello:
Lo script non fa le modifiche, ma solo insert, quindi un records da modificare va prima cancellato nel db e reinserito.


== OLD OLD OLD
Uso: powershell e 
$env:path = "D:\ruby\ruby_2_3_1\bin"
ruby .\race_picker.rb
