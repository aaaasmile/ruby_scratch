# -*- coding: ISO-8859-1 -*-

require 'rubygems'
require 'filescandir'
require 'fileutils'

class JsUIPublisher
  def sync_src_with_dest(src_dir, dst_dir, force_dir_arr)
    @robocopy_path = 'C:\Windows\SysWOW64\Robocopy.exe'
    p "scan src dir"
    src_items = scan_path(src_dir)
    p "scan dst dir"
    dst_items = scan_path(dst_dir)
    
    puts "Src items #{src_items.size}, Dst items #{dst_items.size}" 
    
    p "check for missed files in dst"
    items_not_in_dst = check_presence(src_items, dst_items)
    puts "Items(#{items_not_in_dst.size}) not in destination dir:"
    items_not_in_dst.each do |item|
      puts item
    end
    
    p "check for missed files in src"
    items_not_in_src = check_presence(dst_items, src_items)
    puts "Items(#{items_not_in_src.size}) not in source dir (delete it manually if you do not need it):"
    items_not_in_src.each do |item|
      puts item
    end
    
    p " - COPY STUFF starts here --"
    p "copy src files to dst"
    exclude = ['puesraWebUI.csproj','puesraWebUI.csproj.vspscc','app/config.json', 'packages.config']
    copy_newfiles_to_dest(dst_dir, exclude, items_not_in_dst, src_dir)
    exclude << items_not_in_dst
    exclude.flatten!
    copy_files_to_dest(dst_dir, exclude, src_items, src_dir, force_dir_arr)
    puts "Terminated at #{Time.now}"
  end
  
private
	def copy_files_to_dest(dst_dir, filter_items, src_items, src_dir, force_dir_arr)
		count = 0
		src_items.each do |src_item|
			unless filter_items.index(src_item)
				dst_fname = File.join(dst_dir, src_item)
				src_fname = File.join(src_dir, src_item)
				stat_dst = File.stat(dst_fname)
				stat_src = File.stat(src_fname)
				is_force_item = calc_is_forceitem(src_item, force_dir_arr)
				if (stat_dst.mtime != stat_src.mtime and
					stat_dst.mtime < stat_src.mtime) or is_force_item
					#FileUtils.cp_r(src_fname, dst_fname, :verbose => true)
					robocopy(src_dir, dst_dir, src_item)
					count += 1
					#p stat_dst.mtime
					#p stat_src.mtime
					p "copy #{src_fname} to  #{dst_fname}"
				end
				
			end
		end
		puts "#{count} modified files copied."
	end
	
	def robocopy(src_dir, dst_dir, src_item)
		arr_names = src_item.split('/')
		name = src_item
		name_src_dir = src_dir
		name_dst_dir = dst_dir
		if arr_names.size > 0
			last_ix = arr_names.size - 1
			name = arr_names[last_ix]
			arr_names.delete_at(last_ix)
		end
		arr_names.each do |nn|
			name_src_dir = File.join(name_src_dir, nn)
			name_dst_dir = File.join(name_dst_dir, nn)
		end
		cmd = "#{@robocopy_path} \"#{name_src_dir}\" \"#{name_dst_dir}\" #{name}"
		#puts cmd
		result_cmd = []
		on_error = false
		IO.popen(cmd, "r") do |io|
    	io.each_line do |line|
        on_error = true if line =~ /ERROR/
      	result_cmd << line	 
      end
    end
    if on_error
      puts "ERROR executing #{cmd}"
      result_cmd.each do |line|
        puts line
      end
      puts "!!!!!!! Exit because ERROR on robocopy error,  FIX this error first please!!!!!"
    	exit
    end
	end
		
	
	def calc_is_forceitem(src_item, force_dir_arr)
		item_slash_count = src_item.count('/')
		force_dir_arr.each do |dir|
			dir.gsub!("\\",'/')
			dir_slash_count = dir.count('/') + 1
			#p src_item, dir
			if src_item.include?(dir) and item_slash_count ==  dir_slash_count
				 puts "force #{src_item}"
				 return true
			end
		end
		return false
	end
	
	def copy_newfiles_to_dest(dst_dir, filter_items, items_not_in_dst, src_dir)
		count = 0
		items_not_in_dst.each do |src_item|
			unless filter_items.index(src_item)
				dst_fname = File.join(dst_dir, src_item)
				src_fname = File.join(src_dir, src_item)
				p "new copy #{src_fname} to  #{dst_fname}"
				#FileUtils.cp_r(src_fname, dst_fname)
				robocopy(src_dir, dst_dir, src_item)
				count += 1
			end
		end
		puts "#{count} new files copied." if count > 0
	end

  def scan_path(path_to_scan)
    fscd = FileScanDir.new
    fscd.is_silent = true
    fscd.add_extension_filter(['.cache'])
    fscd.scan_dir(path_to_scan)
    dir_result = []
    
    fscd.result_list.each do |line|
    	dir_result <<  line.gsub(path_to_scan + '/', '')
    end
    return dir_result
  end
  
  def check_presence(src_items, dst_items)
    result = []
    src_items.each do |item|
      is_included = check_included_item(item, dst_items)
      if !is_included
        result << item
      end
    end
    return result
  end
  
  def check_included_item(item_to_find, dst_items)
    dst_items.each do |item|
      if item == item_to_find
        return true
      end
    end
    return false
  end
  
end

if $0 == __FILE__
  src_dir = 'D:\ws\SPMS\user_sartorii_001\Application\puesraWebUI'
  dst_dir = 'C:\Program Files (x86)\apache-tomcat-7.0.57\webapps\puesraWebUI'
  #src_dir = 'D:\ws\openam_custom\12.0.0\war_from_zip\edited'
  #dst_dir = 'C:\Program Files (x86)\apache-tomcat-7.0.57\webapps\openam'
  
  #force_dir = ['Scripts']
  force_dir = []
  sync = JsUIPublisher.new
  sync.sync_src_with_dest(src_dir, dst_dir, force_dir)
end