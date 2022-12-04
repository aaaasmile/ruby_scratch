$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'db_baseitem'
require 'pg'

#Script che uso per fare l'aggiornamento del mio db delle gare memorizzate sul sito pentek
#In questo modo non devo editare le gare due volte, ma solo sul sito Pentek.

#Note: Ho cominciato con arachno e ruby 1.8.6
# il db però usa le stringe in formato utf8 quindi va usato un ruby tipo 2.3.1 quando si va scrivere nel db

class RaceItem < DbBaseItem
  attr_accessor :name,:title,:meter_length,:ascending_meter,:descending,:rank_global,:rank_gender,:rank_class,:class_name,:race_date,:sport_type_id,
        :race_time,:pace_kmh,:pace_minkm,:comment,:race_subtype_id,:runner_id,:km_length
  
  def initialize
    @runner_id = 1
    @sport_type_id = 0 # duathlon is 1. Informazione presente solo nel css background del div //*[@id="zeile_zwei_dua_tacho"]
                       # l'ho messa anche nel titolo
    @ascending_meter = 0
    @changed_fields = [:name,:title,:meter_length,:ascending_meter,:descending,:rank_global,:rank_gender,:rank_class,:class_name,:race_date,:sport_type_id,
          :race_time,:pace_kmh,:pace_minkm,:comment,:race_subtype_id,:runner_id,:km_length]
    @field_types = {:race_date => :datetime, :meter_length => :int, :ascending_meter => :int, :descending => :int, :rank_global => :int,
                    :rank_gender => :int, :rank_class => :int, :sport_type_id => :int, :race_subtype_id => :int, :runner_id => :int, :km_length => :numeric }
  end
  
  def title=(tt)
    # title format example: "race1 (100HM)"
    if tt =~ /\(*.[H,h][m,M]/
      arr = tt.split('(')
      @title = arr[0].strip
      arr[1] = arr[1].downcase
      @ascending_meter = arr[1].gsub("(","").gsub(")","").gsub('hm',"").gsub(" ","").to_i 
    else
      @title = tt.strip
    end
    if @title =~ /Duathlon/
      @sport_type_id = 1
    end
  end
  
  def km_length=(kl)
    @km_length = kl.gsub("k","").to_f
    @meter_length = (@km_length * 1000).to_i 
    if @ascending_meter > 300 and @meter_length != 42195 
      @race_subtype_id = 1
      if @meter_length > 10999 and @meter_length < 42195 
        @race_subtype_id = 7
      elsif @meter_length > 42195
        @race_subtype_id = 6
      end   
    elsif @meter_length < 10999
      @race_subtype_id = 2
    elsif @meter_length == 21097 
      @race_subtype_id = 3
    elsif @meter_length == 42195 
      @race_subtype_id = 4
    elsif @meter_length > 42195 
      @race_subtype_id = 5
    else
      @race_subtype_id = 8
    end 
  end
  
  def rank_global=(rg)
    @rank_global = rg.gsub(".","").to_i
  end
  
  def rank_gender=(rg)
    rank_gender = rg.gsub(".","").to_i
  end
  
  def rank_class=(rg)
    @rank_class = rg.gsub(".","").to_i
  end

  def race_date=(dt)
    @race_date = Time.parse(dt)
  end

  def is_item_recent?(latest_date_in_db)
    @race_date > latest_date_in_db
  end
end

################################################## RACEPICKER

class RacePicker < DbConnectBase
  def initialize
    @log = Log4r::Logger["RacePicker"]
    @agent = Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"
    @picked_races = {}
    if RUBY_VERSION != '1.8.6'
      @str_nbs = "\uc2a0".force_encoding('ISO-8859-1')
      @str_nbs2 = "\u00A0"
    else
      @str_nbs = "\240"
      @str_nbs2 = "\302\240"
    end
    super
    #@str_nbs = "\240" #http://www.utf8-chartable.de/ non breaking space
  end

  def get_latest_racedate_indb
    query = "SELECT race_date, title  FROM race ORDER BY race_date DESC LIMIT 1"
    result = exec_query(query)
    if result.ntuples == 0
      return Time.parse("2000-01-01 00:00:00")
    end
    #p result[0]
    p res = Time.parse(result[0]["race_date"])
    return res
  end

  def is_race_item_indb?(item)
    #p item
    date_str = item.serialize_field_value(:race_date, item.race_date)
    query = "SELECT race_date, title  FROM race WHERE race_date = '#{date_str}' AND title = '#{item.title}' LIMIT 1"
    result = exec_query(query)
    return result.ntuples != 0
  end

  def insert_indb(race_item)
    p race_item
    query = "INSERT INTO race (#{race_item.get_field_title}) VALUES (#{race_item.get_field_values(@dbpg_conn)})" 
    exec_query(query)
  end

  def pick_races(url, latest_date_in_db)
    @log.debug "Url: #{url}, date last race in db #{latest_date_in_db}"
    @log.debug "Using parser #{Mechanize.html_parser}"   # Nokogiri::HTML
    page = @agent.get(url)
    #puts page.body
    i = 1
    @races = []
    #per avere l'elemento che si cerca, si usa select che è un nokogiri con attributes e children
    # per capire cosa bisogna selezionare, basta usare p link all'interno del block select
    page.search("body//div//div//div//div//div").select{|link| link.attributes["id"].value == "ergebnis_container_tacho"}.each do |tacho|   
      #p link
      #p link.inner_html
      @log.debug "Found a new item #{i}..."
      @race_item = RaceItem.new 
      tacho.search('div').select{|ldate| ldate.attributes["id"].value == "ergebnis_bewerbdatum"}.each do |date_race|
        @race_item.race_date = date_race.inner_html.gsub(@str_nbs, "").gsub(/[[:space:]]+\z/,"").strip #remove all spaces, also  &nbsp at the end -> "2016-10-29\xA0\xA0"
      end
      #//*[@id="ergebnis_bewerbname"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "ergebnis_bewerbname"}.each do |item|
        name = nil
        item.search('a').each do |link_a|
          name = link_a.inner_html.gsub(@str_nbs, "") 
        end
        name = item.inner_html if name == nil
        @race_item.name = name.gsub(@str_nbs, "") 
        @race_item.name.strip!
      end 
      #//*[@id="race_tacho"]     
      tacho.search('div').select{|litem| litem.attributes["id"].value == "race_tacho"}.each do |item_value|
        @race_item.title = item_value.inner_html.gsub(@str_nbs, "") #remove non breaking spaces -> &nbsp
      end
      if !@race_item.is_item_recent?(latest_date_in_db)
        #p @race_item.race_date
        @log.debug "Ignore item #{i} - date: #{@race_item.race_date} - #{@race_item.title}.\nSearch is terminated because now all races should be already into the db, but consider to make a consistency check."
        break;
      end
      #//*[@id="distanz_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "distanz_tacho"}.each do |item_value|
        @race_item.km_length = item_value.children.last.text.strip
      end
      #//*[@id="zeit_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "zeit_tacho"}.each do |item_value|
        @race_item.race_time = item_value.children.last.text.strip 
      end
      #//*[@id="minprokm_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "minprokm_tacho"}.each do |item_value|
        @race_item.pace_minkm = item_value.children.last.text.strip.gsub(@str_nbs2,"")
      end
      #//*[@id="kmproh_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "kmproh_tacho"}.each do |item_value|
        @race_item.pace_kmh = item_value.children.last.text.gsub(@str_nbs2, "")
      end
      #//*[@id="gesamtrang_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "gesamtrang_tacho"}.each do |item_value|
        @race_item.rank_global = item_value.children.first.text
      end
      #rank_gender
      #//*[@id="mwrang_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "mwrang_tacho"}.each do |item_value|
        @race_item.rank_gender = item_value.children.first.text
      end
      #rank_class
      #//*[@id="klassenrang_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "klassenrang_tacho"}.each do |item_value|
        @race_item.rank_class = item_value.children.first.text
        @race_item.class_name = item_value.children.last.text.gsub("Kl.","")
      end
      #//*[@id="container_kommentar_tacho"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "container_kommentar_tacho"}.each do |item_value|
        @race_item.comment = item_value.children.last.text
      end
      
      #p @race_item
      @races << @race_item 
      @log.debug "#{@race_item.title} - #{@race_item.race_date}"
      i += 1
      #ergebnis_bewerbdatum
    end
    @log.debug "Found #{@races.length} items that need to be inserted into the db"
    #p @races
  end

  def insert_races_indb
    @races.sort{|a,b| a.race_date <=> b.race_date}.each do |item|
      #insert the oldest new item first
      #p item
      insert_indb(item) 
    end
    if @races.length == 0
      @log.debug "Db is already updated, no new races to insert found"
    else
      @log.debug "Inserted #{@races.length} new races successfully."
    end 
  end

  def check_races(opt)
    insert_missed = opt[:insert_missed]
    @missed_items = []
    @inserted = []
    @races.sort{|a,b| a.race_date <=> b.race_date}.each do |item|
      if is_race_item_indb?(item)
        @log.debug "race item #{item.title} - #{item.race_date} is stored OK"
      elsif insert_missed
        insert_indb(item)
        @inserted << item
        @log.debug "#{item.title} - #{item.race_date} inserted successfully."
      else
        @log.debug "race item #{item.title} - #{item.race_date} is not in the db."
        @missed_items << item
      end
    end
    @log.debug "Checked #{@races.size} races: #{@missed_items.size} are missed"
    if @missed_items.size == 0 && @inserted.size == 0
      @log.debug "Race table in Db is OK (race_date and title, if you have changed other fields, please delete the record into the db and run this check again)"
    elsif @inserted.size > 0 && @missed_items.size == 0
      @log.debug "Inserted #{@inserted.size} races, now db should be sync"
    else
      @log.debug "Please run again check_races with the insert missed option set to true, or use insert_races_indb"
    end
  end

end

if $0 == __FILE__
  # Nota: non è necessario cambiare questo script, basta usare la linea di comando
  #       Quello che fa questo script è andare sul sito di Pentenk, prendere le gare e 
  #       importarle nel database. È in grado di importare solo quelle nuove, ma anche tutte le altre e di fare un check tra il db e il sito.
  require 'log4r'
  include Log4r
  @log = Log4r::Logger.new("RacePicker")
  Log4r::Logger['RacePicker'].outputters << Outputter.stdout

  url = "https://www.membersclub.at/ccmc_showprofile.php?unr=9671&show_tacho=1&pass=008"
  picker = RacePicker.new

  check_consistency = false
  insert_new_races = true
  insert_missed = false
  if ARGV.size > 0
    if ARGV[0] == '/help'
      @log.debug 'Advanced Usage : ruby race_picker.rb "{:check_consistency => true, :insert_missed => false, :insert_new_races => false}"'
      @log.debug 'Advanced Usage2: ruby race_picker.rb "{:check_consistency => true, :insert_missed => true, :insert_new_races => false}"'
      @log.debug "Usual usage: ruby race_picker.rb  (default values: check_consistency = false, insert_new_races = true, insert_missed = false)" 
      exit
    else
      #p ARGV[0]
      opt = eval(ARGV[0])
      check_consistency = opt[:check_consistency]
      insert_missed = opt[:insert_missed]
      insert_new_races = opt[:insert_new_races]
    end
  end
  if insert_missed && !check_consistency
    @log.error ":insert_missed works only with :check_consistency"
  end
  @log.debug "Options are: check_consistency: #{check_consistency} (insert_missed: #{insert_missed}),  insert_new_races: #{insert_new_races}"

  if check_consistency
    picker.pick_races(url, Time.parse("2000-01-01 00:00:00")) 
    picker.check_races({:insert_missed => insert_missed})
  end
  if insert_new_races
    latest_date_in_db = picker.get_latest_racedate_indb
    picker.pick_races(url, latest_date_in_db) 
    picker.insert_races_indb
  end
end
