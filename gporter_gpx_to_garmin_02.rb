# -*- coding: ISO-8859-1 -*-
require 'rubygems'
require 'rexml/document'


class GPorterConvGpx
  
  def parse_gpx(fname)
    p doc_raw = File.open(fname, 'r').read
    doc = REXML::Document.new(doc_raw)
    titles = []
    links = []
    p doc
    doc.elements.each('trk') do |ele|
       titles << ele.name
       p ele
    end
    p titles
  end
  
  # Per fare andare il file gpx su garmin connect partendo da un file esportato
  # da canway bisogna:
  # - Cambiare il nodo gpx, penso che occorra la versione 1.1 anziché la 1.0
  # - Usare il nodo metadata
  # - Togliere il nodo speed in ogni punto
  def remove_speed(fname)
    puts "Open file #{fname}"
    result = []
    line_count = 0
    state = :find_gpx
    old_time = nil
    point_time_insec = nil
    space_in_m = nil
    accumulate_space = 0
    km_tot = 0
    File.open(fname, 'r').each_line do |line|
      insert_line = true
      if state == :insert_metadata
        result << "\n<metadata>\n"
        state = :find_trk
      elsif state == :find_trk and line =~ /trk/
        result << "</metadata>\n"
        state = :normal
      elsif state == :find_gpx and line =~ /gpx/
        insert_line = false
        result << '<gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpsies="http://www.gpsies.com/GPX/1/0" creator="Igor" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.gpsies.com/GPX/1/0 http://www.gpsies.com/gpsies.xsd">'
        state = :insert_metadata
      elsif line =~ /speed/
        insert_line = false
        var = '<speed>'
        var2 = "</speed>\n"
        str2 = line.gsub( /#{Regexp.escape(var)}/, '' )
        str_speed = str2.gsub( /#{Regexp.escape(var2)}/, '' )
        p speed = str_speed.to_f
        p point_time_insec
        if point_time_insec != nil
        	p space_in_m = speed * point_time_insec
        	accumulate_space += space_in_m
        	if accumulate_space >= 1000
            p "Kilometro!!!!!!"
            accumulate_space = 0
            km_tot += 1
          end
        end
      elsif line =~ /time/
        var = '<time>'
        var2 = "</time>\n"
        str2 = line.gsub( /#{Regexp.escape(var)}/, '' )
        str_time = str2.gsub( /#{Regexp.escape(var2)}/, '' )
        mytime = DateTime::strptime(str=str_time)
        if old_time != nil
          diff_time = (mytime - old_time)
          point_time_insec = (diff_time * 24 * 60 * 60).to_i
        end
        old_time = mytime
      end
      if insert_line
        result << line
      end
      line_count += 1
    end
    puts "Percorsi km #{km_tot}"
    out_fname = File.join(File.dirname(fname), "garmin_#{File.basename(fname)}")
    puts "Create a new file without speed item #{out_fname}"
    File.open(out_fname, 'w'){|outfile| result.each{ |item| outfile << item } }
    puts "File created OK - original count #{line_count}, now #{result.size}"
  end
  
end



if $0 == __FILE__
  # NOTA: in questa versione ho provato ad inserire gli split nel file gpx. 
  # Purtroppo non funziona nell'import in garmin connect, anche se si fa il downlad 
  # da garmin connect mi da lo stesso file
  gp = GPorterConvGpx.new
  fname = 'E:\documenti\Tracce_Gps\export_2015-10-18 09-08.gpx'
  gp.remove_speed(fname)
  #gp.parse_gpx(fname)
end