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
  
  def km_length=(kl)
    @km_length = kl.gsub("k","").to_f
    @meter_length = (@km_length * 1000).to_i 
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
    if RUBY_VERSION != '1.8.6'
      @str_nbs = "\uc2a0".force_encoding('ISO-8859-1')
      @str_nbs2 = "\u00A0"
    else
      @str_nbs = "\240"
      @str_nbs2 = "\302\240"
    end
    #@str_nbs = "\240" #http://www.utf8-chartable.de/ non breaking space
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
    #per avere l'elemento che si cerca, si usa select che è un nokogiri con attributes e children
    page.search("body//div//div//div//div//div").select{|link| link.attributes["id"].value == "ergebnis_container_tacho"}.each do |tacho|   
      #p link
      #p link.inner_html
      @race_item = RaceItem.new 
      tacho.search('div').select{|ldate| ldate.attributes["id"].value == "ergebnis_bewerbdatum"}.each do |date_race|
        @race_item.race_date = date_race.inner_html.gsub(@str_nbs, "") #remove non breaking spaces -> &nbsp
      end
      #//*[@id="ergebnis_bewerbname"]
      tacho.search('div').select{|litem| litem.attributes["id"].value == "ergebnis_bewerbname"}.each do |item|
        name = nil
        item.search('a').each do |link_a|
          name = link_a.inner_html.gsub(@str_nbs, "") 
        end
        name = item.inner_html if name == nil
        @race_item.name = name.gsub(@str_nbs, "") 
        #puts race_item.race_date = date_race.inner_html
      end 
      #//*[@id="race_tacho"]     
      tacho.search('div').select{|litem| litem.attributes["id"].value == "race_tacho"}.each do |item_value|
        @race_item.title = item_value.inner_html.gsub(@str_nbs, "") #remove non breaking spaces -> &nbsp
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
        p @race_item.pace_minkm = item_value.children.last.text.strip.gsub(@str_nbs2,"")
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