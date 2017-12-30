# file: race_detail_insert.rb
$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'pg'
require 'db_baseitem'

class RaceDetailItem < DbBaseItem
  attr_accessor : :lap_number, :lap_time, :lap_meter, :lap_pace_minkm, :tot_meter_race, :tot_race_minkm, :race_id
    integer,
     interval,
     int,
     varchar(30),
     int,
     varchar(30),
     int,
    def initialize
      @changed_fields = [:lap_number, :lap_time, :lap_meter, :lap_pace_minkm, :tot_meter_race, :tot_race_minkm, :race_id]
      @field_types = {:lap_number => :int, :lap_meter => :int, :tot_meter_race => :int}
    end
end

class RaceDetailInsert
  def initialize
    @log = Log4r::Logger["RaceDetailInsert"]
  end
end

if $0 == __FILE__
  require 'log4r'
  include Log4r
  @log = Log4r::Logger.new("RaceDetailInsert")
  Log4r::Logger['RaceDetailInsert'].outputters << Outputter.stdout

end