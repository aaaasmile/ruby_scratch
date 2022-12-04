-- statistiche dell'anno
-- Questo script non va lanciato in modo completo, ma vanno selezionate le righe che interressano e poi si preme F5.
-- Uso pgAdmin4 Tools -> Query Tool e qui si carica questo script
-- Il db si aggiorna usando ruby race_picker.rb sotto WLC

-- gare a partire da una data, statistica annuale:
--COPY (
select r.id, r.name, r.title, r.km_length, r.ascending_meter, r.race_date, s.name, r.race_time, r.rank_global, r.rank_class, r.id from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where r.race_date > '2019-01-01' order by r.race_date asc 
--) TO 'D:\scratch\postgres\corsa\race-2018-02.csv' With CSV DELIMITER ';' HEADER; -- export in excel con COPY e TO
-- Nota che excel interpreta questo export come ansi. Per l'utf-8, che è lo standard usato dall'export, vuole il BOM.
-- Quindi con notepad++ o converto in ansi o converto in utf8-bom. Poi apro con excel.

-- delete from race where id = 287 (usa questo delete per cancellare una corsa che risulta in conflitto nel db e poi ricaricala di nuovo con race_picker.rb)

-- sommatorie km e Hm percorsi nell'anno
select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where r.race_date > '2022-01-01' 

-- mostra tutti i tipi di gara (serve per poi vedere quale filtro usare sul tipo)
SELECT * from race_subtype;
-- Numero di ultra
--select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
-- Ultra sopra i cento km
select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 5 OR s.id = 6) 
--AND r.km_length >= 100
--AND r.race_date > '2017-01-01'
order by r.race_date asc 

-- Chilometri totali ultra su asfalto
select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
--select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 5)
--order by r.race_date asc 

-- Chilometri totali ultra su trail
select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
--select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 6) 
--order by r.race_date asc 

-- Numero di Maratone (id = 4)
--select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global, r.id from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 4) 
--order by r.race_date asc 

-- Numero di Mezze Maratone (id = 3)
--select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global, r.id from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 3) 
order by r.race_date asc 

-- delete from race where id = 145 or id = 259
-- select * from race where id = 191

-- Single Marathon
select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global, r.id from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 4) 
--AND r.name LIKE '%Welsch%'
AND r.name LIKE '%VCM%'
order by r.race_date asc 

-- silverster lauf id = 2 fino ai 10km
--select * from race

select r.name, r.title, r.km_length, r.pace_minkm, r.race_date, s.name, r.race_time, r.rank_global, r.id from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 2) 
AND r.title LIKE '%Silve%'
order by r.race_date asc 

select r.title as titolo, r.km_length as distanza, r.race_date as data, r.race_time as tempo, r.rank_global as pos from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 2) 
AND r.title LIKE '%Silve%'
order by r.race_date asc 

-- gare da 10km
select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global, r.id from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 2) AND r.km_length = 10

--alter table race alter column race_time SET DATA TYPE Time USING race_time::time without time zone
-- Prove con il tempo, per le somme dei tempi si usa interval
SELECT ('13:08:57'::interval + '12:07:48'::interval)
SELECT ('09:30:00'::time - '06:00:00'::time) -- risultato interval
--  SELECT (DATE_PART('hour', '08:56:10'::time - '08:54:55'::time) * 3600 +
--               DATE_PART('minute', '08:56:10'::time - '08:54:55'::time)) * 60 +
--               DATE_PART('second', '08:56:10'::time - '08:54:55'::time);


--- Irdning 2017 dettaglio laps
SELECT rd.lap_number, rd.lap_time, rd.lap_pace_minkm, rd.tot_race_time, rd.tot_km_race, rd.tot_race_minkm, 
(rd.tot_km_race / r.km_length * 100) as proc_race_percent, --accumulo della gara
(rd.tot_race_time + r.race_start) as time_in_race -- ora di gara con data
FROM racelap_detail as rd 
inner join race as r
on r.id = rd.race_id
where rd.race_id = 249
-- and (CAST (rd.lap_pace_minkm as interval)  >= '06:30'::interval) 
-- AND (CAST (rd.lap_pace_minkm as interval)  < '07:00'::interval) 
--AND (CAST (rd.lap_pace_minkm as interval)  >= '07:00'::interval) 
--and rd.lap_time <= '00:07:18'::interval -- 7:18 come lap è il tempo dei 06:00 min/km

--select 205.156 - 109 
-- delete from racelap_detail
select * from race
