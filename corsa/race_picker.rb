require 'rubygems'
require 'mechanize'
#Note: sviluppato con arachno e ruby 1.8.6
# il db però usa le stringe in formato utf8 quindi va usato un ruby tipo 2.3.1 quando si va scrivere nel db

class RaceItem
  attr_accessor :name,:title,:meter_length,:ascending_meter,:descending,:rank_global,:rank_gender,:rank_class,:class_name,:race_date,:sport_type_id,
        :race_time,:pace_kmh,:pace_minkm,:comment,:race_subtype_id,:runner_id,:km_length
  
  def initialize
    @runner_id = 1
  end
  
  def title=(tt)
    if tt =~ /\(*.[H,h][m,M]/
      arr = tt.split('(')
      @title = arr[0].strip
      arr[1] = arr[1].downcase
      @ascending_meter = arr[1].gsub("(","").gsub(")","").gsub('hm',"").gsub(" ","") 
    else
      @title = tt.strip
    end
  end
  #def race_date=(dt_str)
    ##arr = dt_str.split('-')
    #@race_date = dt_str
  #end
end

class RacePicker
  def initialize
    @agent = Mechanize::Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"
    @picked_races = {}
  end
  
  def pick_races(url)
    p Mechanize.html_parser # Nokogiri::HTML
    page = @agent.get(url)
    #puts page.body
    i = 0
    #page.search('body//div//div//div//div//div').set('class','ergebnis_container_tacho').each do |element|
    #page.search("body//div//div//div//div//div").each do |element|
    #element.search('div//div').each do |field|
    #  p field.inner_html
    #end
    @races = []
    page.search("body//div//div//div//div//div").select{|link| link.attributes["id"].value == "ergebnis_container_tacho"}.each do |tacho|   
      #p link
      #p link.inner_html
      @race_item = RaceItem.new 
      tacho.search('div').select{|ldate| ldate.attributes["id"].value == "ergebnis_bewerbdatum"}.each do |date_race|
        p @race_item.race_date = date_race.inner_html.gsub("\xA0", "") #remove non breaking spaces -> &nbsp
      end
      #//*[@id="ergebnis_bewerbname"]
      tacho.search('div').select{|ldate| ldate.attributes["id"].value == "ergebnis_bewerbname"}.each do |item|
        name = nil
        item.search('a').each do |link_a|
          name = link_a.inner_html
        end
        name = item.inner_html if name == nil
        p @race_item.name = name.gsub("\xA0", "") 
        #puts race_item.race_date = date_race.inner_html
      end 
      #//*[@id="race_tacho"]     
      tacho.search('div').select{|litem| litem.attributes["id"].value == "race_tacho"}.each do |item_value|
        @race_item.title = item_value.inner_html.gsub("\xA0", "") #remove non breaking spaces -> &nbsp
      end
      p @race_item
      exit if i == 1
      i += 1
      #ergebnis_bewerbdatum
      @races << @race_item 
    end
  end
end

if $0 == __FILE__
  url = "http://www.membersclub.at/ccmc_showprofile.php?unr=9671&show_tacho=1&pass=008"
  picker = RacePicker.new
  picker.pick_races(url) 
end

#div id = ergebnis_container_tacho