# file: race_detail_insert.rb
$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'pg'
require 'db_baseitem'

############################# RaceDetailItem

class RaceDetailItem < DbBaseItem
  attr_accessor :lap_number, :lap_time, :lap_meter, :lap_pace_minkm, :tot_meter_race, :tot_race_minkm, :race_id

  def initialize
    @changed_fields = [:lap_number, :lap_time, :lap_meter, :lap_pace_minkm, :tot_meter_race, :tot_race_minkm, :race_id]
    @field_types = {:lap_number => :int, :lap_meter => :int, :tot_meter_race => :int}
  end

end

################################ RaceDetailInsert

class RaceDetailInsert < DbConnectBase
  def initialize
    @log = Log4r::Logger["RaceDetailInsert"]
    super
  end

  def get_race_reference(title, date)
    query = "SELECT id, race_date, title  FROM race WHERE race_date = '#{date}' AND title = '#{title}' LIMIT 1"
    result = exec_query(query)
    if result.ntuples == 1
      #p result[0]
      id_res = result[0]["id"]
      @log.debug "Referenced race is #{title} at #{date} with id #{id_res}"
      return id_res
    else
      raise "Race #{title} at #{date} not found"
    end
  end
end

if $0 == __FILE__
  require 'log4r'
  include Log4r
  @log = Log4r::Logger.new("RaceDetailInsert")
  Log4r::Logger['RaceDetailInsert'].outputters << Outputter.stdout

  inserter = RaceDetailInsert.new
  race_id = inserter.get_race_reference('24h-Einzel-Bewerb','2017-06-30')
end