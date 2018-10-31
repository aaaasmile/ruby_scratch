# -*- coding: ISO-8859-1 -*-

require 'erb'


fullname = File.dirname(__FILE__) + "/bs_import.rtemp"
file = File.new(fullname, "r")
template = ERB.new(file.read)
file.close

(31..60).each do |ix|
  @bsname = "BS"
	@bsname += ix < 10 ? "0#{ix}" : "#{ix}"
	puts aString = template.result(binding)
end