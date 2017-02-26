require 'rubygems'
require 'mechanize'

class EtfQuoteFinanzNet
  
  def initialize
    @agent = Mechanize::Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"
    @picked_quote = {}
  end
  
  def pick_from_complete_url(url)
    page = @agent.get(url)
    #puts page.body
    page.search('body//div//div//div//div//div//div//div//div//div//div').set('class','col-xs-4 col-sm-4 text-sm-right text-nowrap').each do |element|
      p element.inner_html
      # non è utilizzabile in quanto manca Xetra, mentre usa Stuggard e NAV
    end
  end
  
  def pick_from_easychart(url)
    page = @agent.get(url)
    data_found = []
    #'body//div//div//div//div//table//tbody//tr//td//table//tbody//tr//td//table//tbody//tr//td//table//tbody//tr//td'
    #page.search('body//div//div//div//div//td//b').set('class','last').each do |element|
    element_with_quote = false
    # devo trovare il tr con la classe 'toptitle' e poi vedere il successivo tr. Nei children td ci sono le info che  mi servono
    page.search('body//div//div//div//div//table').set('class','datatable').search('tr').each do |element|
      #p element.inner_html
      if element_with_quote
        #p element.inner_html
        i = 0
        element.search('td').each do |field|
          if i == 0 || i == 1 || i == 4 || i == 5
            item = field.inner_html.gsub(' ','')
            data_found << item.gsub(/\r\n/,'')
          elsif i == 2
            data_found << field.search('b')[0].inner_html
          end
          i = i + 1
          #p fields.inner_html  
        end
        break
      end
      if element.attributes['class'] && (element.attributes['class'].value == 'toptitle')
        #p element.inner_html
        element_with_quote = true # mark the next item  
      end
    end
    p data_found
    @picked_quote[data_found[0]] = data_found
  end
  
  def write_quotes(fname)
    File.open(fname,'w') do |file|
      @picked_quote.each do |k,v|
        file.write(v.join(';'))
        file.write("\n")
      end
    end
    puts "File written #{fname}"
    p @picked_quote
  end
  
end



if $0 == __FILE__
  #url = 'http://www.finanzen.net/etf/db_x-trackers_DBLCI_-_OY_BALANCED_UCITS_ETF_EUR_1C'
  #picker.pick_from_complete_url(url)
  
  urls = []
  
  #LU0292106167
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-11057070&menuId=1&pathName=DB%20X-TR.DBLCI-OY%20BAL.%201C'
  
  picker = EtfQuoteFinanzNet.new
  urls.each do |url|
    picker.pick_from_easychart(url)
  end
  
  picker.write_quotes('D:\scratch\csharp\PortfolioExcelChecker\PortfolioExcelChecker\bin\Debug\quote.csv')
  
end