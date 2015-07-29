# file: gpx_redux.rb

##
# Used to reduce gpx tracks or split into more files
class GpxReducer
  
  def initialize
    @header = []
    @footer = []
    @all_points = []
    @gpx_fname = ''
  end
     
  def points_counter(fname)
    @gpx_fname = fname
    header = []
    footer = []
    curr_point = []
    all_points = []
    state = :init_seg
    points_count = 0
    File.open(fname).each_line do |line|
      if line =~ /<trkseg/
        header << line
        state = :init_point
      elsif line =~ /<trkpt/
        # inizio punto
        if state == :init_point
          state = :on_point
          points_count += 1
          curr_point = []
          curr_point << line
        end
      elsif line =~ /<\/trkpt/
        # fine punto
        if state == :on_point
          curr_point << line
          #puts"current point\n#{curr_point}"
          all_points << curr_point
          state = :init_point
        end
      elsif line =~ /<\/trkseg/
        # fine traccia
        footer << line
        state = :end_file
      else
        if state == :init_seg
          header << line
        elsif state == :end_file
          footer << line
        elsif state == :on_point
          curr_point << line
        end
      end
    end # file open
    puts "Header:\n#{header}"
    puts "Footer:\n#{footer}"
    
    puts "Points count: #{points_count}(#{all_points.size}) for file #{fname}"
    @all_points = all_points
    @footer = footer
    @header = header
  end
  
  def gpx_splitter(num_of_tracks)
    if @all_points.size == 0
      puts "Call firts points_counter() to get points information. No points recognized"
      return
    end
    if num_of_tracks < 2
      puts "Nothing to do, use the souce track if you want"
    end
    
    points_per_track = @all_points.size / num_of_tracks
    tracks = []
    in_track_points = []
    @all_points.each do |point|
      in_track_points << point
      if in_track_points.size >= points_per_track and tracks.size < num_of_tracks - 1 
        tracks << in_track_points
        in_track_points = []
      end
    end
    tracks << in_track_points
    
    ix_track = 1
    tracks.each do |track|
      trackname = "Track#{ix_track}.gpx"
      complete_track = []
      complete_track << @header
      complete_track << track
      complete_track << @footer
      #puts "Track #{ix_track}:\n#{complete_track}"
      puts "Points in #{trackname} are: #{track.size}"
      File.open(trackname, 'w'){|f| complete_track.flatten.each{|x| f << x}}
      puts "File written #{trackname}"
      ix_track += 1
    end
    
  end
  
  def reduce_half(fname)
    arr_res = []
    state = :init_point
    count_lines = 0
    File.open(fname).each_line do |line|
      #p line
      count_lines += 1
      if line =~ /<trkpt/
        # inizio punto
        if state == :init_point
          state = :on_point
          arr_res << line
        else
          p "skip IP (#{state}): #{line}"
        end
      elsif line =~ /<\/trkpt/
        # fine punto
        if state == :on_point
          arr_res << line
          state = :jump__next_point
        elsif state == :jump__next_point
          p "skip OP (#{state}):  #{line}"
          state = :init_point
        end
      elsif line =~ /<\/trkseg/
        # fine traccia
        state = :end_file
        arr_res << line     
      else
        if state != :jump__next_point
        	arr_res << line
        else
          p "skip OTHer (#{state}): #{line}"
        end 
      end
    end
    jumped_points = (count_lines - arr_res.size) / 4
    puts "Lines on file now #{arr_res.size}, original lines #{count_lines}, jumped points #{jumped_points}"
    res_fname = 'out_reduced.gpx'
    File.open(res_fname, 'w'){|f| arr_res.each{|x| f << x}}
    puts "File created #{res_fname}"
  end
	
end



if $0 == __FILE__
  # Usa questo script per ridurre una traccia della metà e poi magari farne uno split.
  # Con Canmore è meglio avere dei files con intorno 700 punti massimo, per aprirli e scalarli
  # in tempi ragionevoli. I nomi dei files vanno anche cambiati manualmente usando notepad.
  # Usa qualcosa tipo 1- desc traccia1 e così via. Sono tre i punti nel file xml da cambiare, dove compare il tag <name>
  # Usa poi Canway Planner e importa tutte le traccie in un colpo prima di sincronizzare col device.
  # Se fai degli errori, chiudi Canway Planner e ricomincia. Le traccie sul device vanno cancellate manulamente
  # usando file explorer nel subfolder trips.
  # Con il file del Dirndltal Extrem scaricato da gpsies, aveva 1924 punti che ho splitato in 3 files da 641 punti.
  gr = GpxReducer.new
  fname = 'E:\corsa\2015\DirndtalExtreme\OfficialGpsIes\DirndltalExtremUltratrail_gpsies.gpx'
  #gr.reduce_half(fname)
  gr.points_counter(fname)
  #gr.gpx_splitter(3)
end