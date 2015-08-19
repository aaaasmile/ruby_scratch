# Show differences between two play-lists.
# Play-lists are created using gtkpod with two different ishuffle devices (green and silver)
# To sync files, use gtkpod instead of the rhythmbox because dragging files between two devices
# does not works.
# Create a list in gtkpod with Tools->Export Tracks -> export to playlist

require 'rubygems'


class PlayListDifference

  def show_diff(master, slave, options)
    count_item = 0
    slave_name = options.has_key?(:slave_name) ? options[:slave_name] : "slave"
    File.open(master, 'r').each_line do |line|
      if line =~ /EXTINF/
        title = line.split(',')[1].strip.gsub('\n', '')
        #puts title
        present_in_slave_info = check_title_in_list(slave, title)
        present_in_slave = present_in_slave_info[:exact] > 0
        partial_in_slave = present_in_slave_info[:partial] > 0
        if !present_in_slave
          if !partial_in_slave
          	puts "'#{title}' is missed in #{slave_name}"
          elsif options[:print_partial] == true
            puts "'#{title}' is partial in #{slave_name}: '#{present_in_slave_info[:partial_titles]}'"
          end
        end
        count_item = count_item + 1
      end
    end
    puts "Found #{count_item} titles"
  end
  
  def check_title_in_list(fname, tobe_found)
    count_item = 0
    partial = 0
    partial_arr = []
    arr = tobe_found.split('- ')
    song_title_only = arr.length > 0 ? arr[arr.length - 1].gsub('.mp3', "") : nil
    File.open(fname, 'r').each_line do |line|
      if line =~ /EXTINF/
        title = line.split(',')[1].strip.gsub('\n', '')
        #if title.include?(tobe_found)
        if title == tobe_found
          #puts "Title '#{tobe_found}' found in '#{title}'"
          count_item += 1
        else
          if song_title_only != nil
          	if title.include?(song_title_only)
          		partial += 1
          		partial_arr << title
          	end
          else
            #p tobe_found
        	end
        end
      end
    end
    if partial == 0 and count_item == 0
      #p song_title_only
    end
    return {:exact => count_item, :partial => partial, :partial_titles => partial_arr} 
  end
  
end


if $0 == __FILE__
  silver_file = 'silver_playlist_2015_08_19'
  green_file = 'green_playlist_2015_08_19'
  diff = PlayListDifference.new
  
  diff.show_diff(green_file, silver_file, {:print_partial => false, :slave_name => "silver"})
  diff.show_diff(silver_file, green_file,  {:print_partial => false, :slave_name => "green"})
end
