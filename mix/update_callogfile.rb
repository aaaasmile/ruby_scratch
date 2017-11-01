# -*- coding: ISO-8859-1 -*-

require 'rubygems'

require 'log4r'

include Log4r

class FileAppenderExtraSim
  
  def initialize
    @log = Log4r::Logger.new("FileAppenderExtraSim")
    @log.outputters << Outputter.stdout
    #FileOutputter.new('FileAppenderExtraSim', :filename=> 'FileAppenderExtraSim.log') 
    #Logger['FileAppenderExtraSim'].add 'FileAppenderExtraSim'
  end
  
  def getnumLinesWritten(target_file)
    res = 0
    if File.exist?(target_file)
    	res = File.open(target_file).readlines.size
    end
    return res
  end
  
  def write_some_lines(src_file, target_file, num_to_write)
    @log.debug("process #{src_file}")
    src_lines = []
    num_in_target = getnumLinesWritten(target_file)
    @log.debug("Num lines written in target #{num_in_target}")
    i = 0 
    File.open(src_file).each_line do |line|
      if i >= num_in_target and src_lines.length < num_to_write
        src_lines << line
      end
      i += 1
    end
    @log.debug("Source file has #{i} lines, jump the first #{num_in_target} lines and writes #{num_to_write} lines.")
    File.open(target_file, 'a'){|f| src_lines.each{|x| f << x}}
    @log.debug("Target file #{target_file} has been updated with #{num_to_write} lines")
  end
  
  ##
  # Append lines into the target file using the src_file. Timeout in seconds is used to do the append. 
  # Lines already written into the target are skipped, so you can restart and stop this function and the append process continue.
  def write_lines_after_timeout(src_file, target_file, numrecords, timeout)
    @log.debug("process #{src_file}")
    src_lines = []
    num_in_target = getnumLinesWritten(target_file)
    @log.debug("Num lines written in target #{num_in_target}")
    i = 0 
    File.open(src_file).each_line do |line|
      if i >= num_in_target
        src_lines << line
      end
      i += 1
    end
    
    @log.debug("Start to writes lines after #{timeout} seconds, lines to be written are #{src_lines.size}")
    written = 0
    arr_num = numrecords.dup
    while src_lines.size > 0
     	sleep timeout
     	num_to_write = arr_num.pop 
     	curr_slice = src_lines.slice!(0..num_to_write - 1)
     	File.open(target_file, 'a'){|f| curr_slice.each{|x| f << x}}
     	written += curr_slice.size
     	@log.debug("#{curr_slice.size} lines appended, written in this session until now are #{written}")
     	if arr_num.length == 0
        arr_num = numrecords.dup
      end  
    end
  end
  
  
end

if $0 == __FILE__
  app = FileAppenderExtraSim.new
  
  numrec = 5
  #src_file = 'C:\temp\SPMS\bs01\Archive\calls_2014.11.03.log'
  #target_file = 'C:\temp\KPI\bs01\logs\calls_2014.11.03.log'
  #app.write_some_lines(src_file, target_file, numrec)
  
  #change the update file
  src_file = 'C:\temp\SPMS\bs01\Archive\calls_2014.11.04.log'
  target_file = 'C:\temp\KPI\bs01\logs\xcalls_2015.11.06.log'
  app.write_some_lines(src_file, target_file, numrec)
  
  
  timeout = 1
  numrecords = [5,4,3,2,1]
  #numrecords = [1]
  #app.write_lines_after_timeout(src_file, target_file, numrecords, timeout)
end