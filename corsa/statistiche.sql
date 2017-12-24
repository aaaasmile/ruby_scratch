-- statistiche dell'anno

-- gare
select r.name, r.title, r.km_length, r.race_date, s.name, r.race_time, r.rank_global from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where r.race_date > '2017-01-01' order by r.race_date desc 

-- sommatorie km e Hm percorsi nell'anno
select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where r.race_date > '2017-01-01' 

-- Numero di ultra
SELECT * from race_subtype;

--select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global from race as r
inner join race_subtype s on r.race_subtype_id = s.id
where
(s.id = 5 OR s.id = 6) 
AND r.km_length >= 100
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
select SUM(r.km_length) as Km_Tot, SUM(r.ascending_meter) as HM_Tot  from race as r
--select r.name, r.title, r.km_length, r.ascending_meter as HM, r.race_date, s.name, r.race_time, r.rank_global, r.id from race as r
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





