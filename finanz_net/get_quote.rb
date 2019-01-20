require 'rubygems'
require 'mechanize'

class EtfEasyChart
  
  def initialize
    @agent = Mechanize::Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"
    @picked_quote = {}
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
        # qui una linea separata da td di questo tipo: LU0292106167 XetraETF 18,39 24.02./17 36 -0,05/-0,27%
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
    #p data_found
    data_found << url
    @picked_quote[data_found[0]] = data_found
  end
  
  def write_quotes(fname)
    File.open(fname,'w') do |file|
      @picked_quote.each do |k,v|
        file.write(v.join(';'))
        file.write("\n")
        puts "ISIN: #{v[0]}, quote: #{v[2]}"
      end
    end
    puts "File written #{fname}"
    #p @picked_quote
  end
  
end



if $0 == __FILE__
  #url = 'http://www.finanzen.net/etf/db_x-trackers_DBLCI_-_OY_BALANCED_UCITS_ETF_EUR_1C'
  #picker.pick_from_complete_url(url)
  puts "get_quote.rb is using hard coded urls..."
  
  urls = []
  # 1 LU0290357929  db x-trackers II iBoxx Global Infl.-linked UCITS ETF 1C
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-10904993&menuId=1&pathName=DB%20X-TR.II-IB.GL.IN.-L.1C'
  # 2 LU0290355717  db x-trackers II iBoxx Sov. Eurozone UCITS ETF 1C
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-10904984&menuId=1&pathName=DBXTR.II-EUROZ.G.B.(DR)1C'
  # 3 LU0292106167  db x-trackers DBLCI - OY Balanced UCITS ETF 1C
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-11057070&menuId=1&pathName=DB%20X-TR.DBLCI-OY%20BAL.%201C'
  # 4 LU0489337690 db x-trackers FTSE EPRA/NAREIT Dev. Europe Real Estate
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-23270949&menuId=1&pathName=DB%20X-T.FTSE%20E/N%20DE%20RE%201C'
  # 5 IE00B1FZS350  iShares Developed Markets Property Yield UCITS ETF
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-106098910&menuId=1&pathName=ISHSII-DEV.MKT.PR.Y.DLDIS'
  # 6 IE00B3VWM098  iShares MSCI USA Small Cap UCITS ETF B
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-20534544&menuId=1&pathName=ISHSVII-MSCI%20USA%20SC%20DL%20AC'
  # 7 IE00B2QWDY88  iShares MSCI Japan Small Cap UCITS ETF (Acc) B
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-75100612&menuId=1&pathName=ISHSIII-MSCI%20J.SM.CAP%20DLD'
  # 8 IE00B3VWMM18  iShares MSCI EMU Small Cap UCITS ETF B
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-20534543&menuId=1&pathName=ISHSVII-MSCI%20EMU%20SC%20EOACC'
  # 9 DE000A0D8Q49  iShares DJ U.S. Select Dividend (DE)
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-3372758&menuId=1&pathName=IS.DJ%20U.S.SELEC.DIV.U.ETF'
  #10 LU0292107645  db x-trackers MSCI EM TRN UCITS ETF 1C
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-10980122&menuId=1&pathName=DB%20X-TR.MSCI%20EM%20IDX.1C'
  #11 IE00B0M63060  iShares UK Dividend UCITS ETF
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-105446142&menuId=1&pathName=ISHS-UK%20DIVIDEND%20LS%20D'
  #12 DE000A0H0744  iShares DJ Asia Pacific Select Dividend 30
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-4076332&menuId=1&pathName=IS.DJ%20AS.PAC.S.D.30%20U.ETF'
  #13 DE0002635281  iShares EURO STOXX Select Dividend 30 (DE)
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-2794238&menuId=1&pathName=IS.EO%20ST.SEL.DIV.30%20U.ETF'
  #14 IE00BM67HM91  db x-tr.MSCI Wld.Energy I.ETF
  urls << 'http://www.easycharts.at/index.asp?action=securities_securityDetails&id=tts-102824320&menuId=1&pathName=DB-XTR.MSCI%20WEIU(PD)%201CDL'
  
  picker = EtfEasyChart.new
  urls.each do |url|
    picker.pick_from_easychart(url)
  end
  
  picker.write_quotes('D:\scratch\csharp\PortfolioExcelChecker\PortfolioExcelChecker\bin\Debug\quote.csv')
  
end