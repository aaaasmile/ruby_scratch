# -*- coding: ISO-8859-1 -*-
require 'rubygems'
require 'log4r'

include Log4r

class WindowsServiesStartOrStop
  
  def initialize
    @log = Log4r::Logger.new("WindowsServiesStartOrStop")
    @log.outputters << Outputter.stdout
    FileOutputter.new('WindowsServiesStartOrStop', :filename=> 'services.log') 
    Logger['WindowsServiesStartOrStop'].add 'WindowsServiesStartOrStop'
  end
  
  def StopServices(serv_arr)
    @log.debug "Stopping #{serv_arr}"
    submit_net_cmd(:stop, serv_arr)
  end
  
  def StartServices(serv_arr)
    @log.debug "Starting #{serv_arr}"
    submit_net_cmd(:start, serv_arr)
  end
  
  private
  
  def submit_net_cmd(cmd_type,serv_arr )
    net_cmd = "start"
    if cmd_type == :stop
      net_cmd = "stop"
    end
    serv_arr.each do |service|
      cmd = "net #{net_cmd} \"#{service}\""
      ExecCmd(cmd)
    end
    @log.debug "All #{net_cmd} requests submitted" 
  end
  
  def ExecCmd(cmd)
    IO.popen(cmd, "r") do |io|
    	io.each_line do |line|
       	@log.debug line
      end
    end
  rescue
   	@log.error "Error: #{$!}"
  end
  
end


if $0 == __FILE__
  services = []
  services << 'SPMS - Administration Service'
  services << 'SPMS - Aggregation Service'
  services << 'SPMS - Authorisation Service'
  services << 'SPMS - DNS Service' 
  services << 'SPMS - ETL Service' 
  services << 'SPMS - LogFile Watcher Service'
  services << 'SPMS - Reporting Service'
  services << 'SPMS - Scheduler Service'
  
  # SINGLE SERVICE
  #services = ['SPMS - Authorisation Service']
  #services = ['SPMS - Reporting Service']
  #services = ['SPMS - LogFile Watcher Service']
  #services = ['SPMS - Aggregation Service']
  #services = ['SPMS - ETL Service']
  #services = ['SPMS - Administration Service']
  #services = ['SPMS - Scheduler Service']
  #services = ['SPMS - Reporting Service', 'SPMS - ETL Service']
  #services = ['SPMS - LogFile Watcher Service', 'SPMS - ETL Service']
  
  ####
  starter = WindowsServiesStartOrStop.new
  
  starter.StopServices(services)
  #starter.StartServices(services)
  
 
end
