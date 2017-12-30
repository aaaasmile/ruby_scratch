# file: race_detail_insert.rb
require 'rubygems'
require 'pg'

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