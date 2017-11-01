# -*- coding: ISO-8859-1 -*-
require 'rubygems'
require 'fileutils'
require 'filescandir'


class ExtraSPMSLogCreator
  def create_structure(low_ix, up_ix, root_dir, src_files_dir)
    fscd = FileScanDir.new
    fscd.scan_dir(src_files_dir)
    
    (low_ix..up_ix).each do |ix|
  	  bsname = "BS"
		  bsname += ix < 10 ? "0#{ix}" : "#{ix}"
  	  fullname_bs_dir = File.join(root_dir,bsname)
		  FileUtils::mkdir_p fullname_bs_dir
		  FileUtils::mkdir_p  File.join(fullname_bs_dir, "Archive")
		  FileUtils::mkdir_p  File.join(fullname_bs_dir, "Error")
		  target_logs_dir = File.join(fullname_bs_dir, "Logs")
		  FileUtils::mkdir_p target_logs_dir
			fscd.result_list.each do |line|
    		dst_item = File.join(target_logs_dir, File.basename(line))
    		FileUtils.cp line, dst_item
    	end  
		  puts "Created structure in #{fullname_bs_dir}"
		end
	end
end

if $0 == __FILE__
	root_dir = 'D:/tmp/cancme'
	src_call_logs_dir = 'C:/temp/SPMS/BS03/Logs'
	log_build = ExtraSPMSLogCreator.new
	log_build.create_structure(1,3,root_dir, src_call_logs_dir)
end


