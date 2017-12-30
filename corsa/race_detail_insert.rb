# file: race_detail_insert.rb
$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'pg'
require 'db_baseitem'
require 'time'

############################# RaceDetailItem

class RaceDetailItem < DbBaseItem
  attr_accessor :lap_number, :lap_time, :lap_meter, :lap_pace_minkm, :tot_meter_race, :tot_race_minkm, :race_id, :tot_race_time, :tot_km_race, :completed

  def initialize
    @changed_fields = [:lap_number, :lap_time, :lap_meter, :lap_pace_minkm, :tot_meter_race, :tot_race_minkm, :race_id, :tot_race_time, :tot_km_race, :completed]
    @field_types = {:lap_number => :int, :lap_meter => :int, :tot_meter_race => :int, :completed => :boolean}
  end

end

################################ RaceDetailInsert

class RaceDetailInsert < DbConnectBase
  def initialize
    @log = Log4r::Logger["RaceDetailInsert"]
    super
  end

  def get_race_reference(title, date)
    query = "SELECT id, race_date, title, km_length, lap_meter, tot_race_time_sec  FROM race WHERE race_date = '#{date}' AND title = '#{title}' LIMIT 1"
    result = exec_query(query)
    if result.ntuples == 1
      #p result[0]
      id_res = result[0]["id"]
      km_res = result[0]["km_length"].to_f
      lap_meter = result[0]["lap_meter"].to_f
      raise "Lap is null (lap_meter), please insert it manually (race id #{id_res})" if lap_meter == 0
      tot_race_time_sec = result[0]["tot_race_time_sec"].to_i
      raise "Race time is null (tot_race_time_sec), please insert it manually (race id #{id_res})" if tot_race_time_sec == 0

      @log.debug "Referenced race is #{title} at #{date} with id #{id_res}, km #{km_res}, lap #{lap_meter}, tot time sec #{format_seconds(tot_race_time_sec)}"
      return [id_res, km_res, lap_meter, tot_race_time_sec] 
    else
      raise "Race #{title} at #{date} not found"
    end
  end

  def format_seconds(tot_time_sec)
    hh = (tot_time_sec / 3600).floor
    min = ((tot_time_sec - (3600 * hh)) / 60).floor
    ss = tot_time_sec - (3600 * hh) - (60 * min)
    time_str = pad_to_col(hh.to_s, "0", 2) + ':' + pad_to_col(min.to_s, "0", 2) + ':' + pad_to_col(ss.to_s, "0", 2) ;
  end

  #Provides a pace string. Something like "06:41" for a velocity of 8.98 km/h
  def calc_pace_in_min_sec(meter, sec)
    dist_km = meter / 1000.0
    vel_m_sec = meter / sec
    vel_med_in_kmh = vel_m_sec * 3.6
    min_part = 1000 / (vel_med_in_kmh / 3.6) / 60  # qualcosa come 4,3 min ma noi interessa tipo 4min 20sec
    pace_str = make_min_form(min_part)
  end

  # Transform the minute velocity  fraction in mm:sec format. E.g 4.3 => "04:20"
  def  make_min_form(min_part) 
    min_only = min_part.floor;
    sec_perc = min_part - min_only;
    sec_only = 60 * sec_perc;
    if (sec_only > 59.5)
        min_only += 1
        sec_only = 0
    end
    mm_formatted = pad_to_col(min_only.to_s, "0", 2) + ':' + pad_to_col(sec_only.round.to_s, "0", 2);
    return mm_formatted;
  end

  def pad_to_col(str, pad, width)
    str_res = "" + str;
    while (str_res.length < width) 
      str_res = pad + str_res
    end
    return str_res.slice(0, width)
  end 

  # lap_meter: lunghezza del lap in metri
  # tot_race_time_sec: durata della gara, esempio irdning 3600 * 24
  # km_race: km percorsi al termine della gara (finale)
  # data_file: file con i tempi parziali di ogni giro percorso
  # race_id : referenza della gara (esempio irdning id = 249)
  def create_laps(race_id, data_file, lap_meter, km_race, tot_race_time_sec, insert_last_partial)
    fname = File.join(File.dirname(__FILE__), data_file)
    lap_nr = 1
    tot_meter = 0
    tot_time_sec = 0
    @items = []
    File.open(fname, 'r').each_line do |line|
      arr_laps_str = line.split(" ")
      arr_laps_str.each do |value_s|
        #p value_s
        t1 = Time.parse(value_s)
        #p t1.methods
        lap_sec = t1.hour * 3600 + t1.min * 60 + t1.sec
        tot_time_sec += lap_sec
        tot_meter = lap_meter * lap_nr  
        item = RaceDetailItem.new
        item.lap_number = lap_nr
        item.lap_time = value_s
        item.lap_meter = lap_meter
        item.lap_pace_minkm = calc_pace_in_min_sec(lap_meter, lap_sec) 
        item.tot_meter_race = tot_meter
        item.tot_race_minkm = calc_pace_in_min_sec(tot_meter, tot_time_sec) 
        item.race_id = race_id
        item.tot_race_time = format_seconds(tot_time_sec)
        item.tot_km_race = tot_meter / 1000
        item.completed = true
        #p item
        @items << item
        lap_nr += 1
        #exit if lap_nr == 9
      end
      #p line
    end
    @log.debug "Collected #{@items.size} laps. Completed laps km #{@items.last.tot_km_race} in #{@items.last.tot_race_time} "

    # last lap is not completed but it is the difference between total km and the last completed sum
    if insert_last_partial
      t1 = Time.parse(@items.last.tot_race_time)
      completed_lap_sec = t1.hour * 3600 + t1.min * 60 + t1.sec
      lap_sec = tot_race_time_sec - completed_lap_sec
      item = RaceDetailItem.new
      item.lap_number = lap_nr
      item.lap_time = format_seconds(lap_sec)
      item.lap_meter = km_race * 1000 - @items.last.tot_km_race * 1000
      item.lap_pace_minkm = calc_pace_in_min_sec(item.lap_meter, lap_sec) 
      item.tot_meter_race = km_race * 1000
      item.tot_race_minkm = calc_pace_in_min_sec(km_race * 1000, tot_race_time_sec) 
      item.race_id = race_id
      item.tot_race_time = format_seconds(tot_race_time_sec)
      item.tot_km_race = km_race
      item.completed = false
      #p item
      @items << item
    end
    
  end #end create_laps

  def store_laps_indb
  end

end

if $0 == __FILE__
  require 'log4r'
  include Log4r
  @log = Log4r::Logger.new("RaceDetailInsert")
  Log4r::Logger['RaceDetailInsert'].outputters << Outputter.stdout

  inserter = RaceDetailInsert.new
  arr_res = inserter.get_race_reference('24h-Einzel-Bewerb','2017-06-30')
  race_id = arr_res[0]
  km_race = arr_res[1]
  lap_meter = arr_res[2]
  tot_race_time_sec = arr_res[3]
  #lap_meter = 1217.75
  #tot_race_time_sec = 3600 * 24
  insert_last_partial = true
  inserter.create_laps(race_id, 'data/2017-06-30-24h-irdning.txt', lap_meter, km_race, tot_race_time_sec, insert_last_partial)
  inserter.store_laps_indb
end