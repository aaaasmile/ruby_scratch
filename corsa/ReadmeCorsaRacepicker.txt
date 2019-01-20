== Sommario
race_picker.rb:
Script che uso per fare l'aggiornamento del mio db delle gare memorizzate sul sito pentek
In questo modo non devo editare le gare due volte, ma solo sul sito Pentek.

Lo script aggiorna il mio database posgres dove memorizzo i dati delle gare.

Uso: powershell e 
$env:path = "D:\ruby\ruby_2_3_1\bin"
ruby .\race_picker.rb


== Parametri
Ci sono varie opzioni che consentono di fare un check di integrità dei dati. Il check tra il sito pentek e il mio db.
Il comando da usare:
ruby .\race_picker.rb  "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}"

cambiando i paramteri è possibile fare gli inserimenti nel db. Comunque senza parametri inserisce solo le nuove corse,
che poi è lo standard da usare.

== Database
Usa il database locale corsadb
