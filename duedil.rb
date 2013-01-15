require 'Nokogiri'
require 'open-uri'
require 'csv'

@reg = []

# Read company registration data
CSV.foreach(File.join(File.dirname(__FILE__), 'sample-data.csv')) do |row|
  @reg << row
end

@reg.each do |c|
  url = "https://www.duedil.com/company/#{c[1]}/"
  begin
    # Get cash from Duedil    
    page = Nokogiri::HTML(open(url))
    cash = page.css("#widget_headlinefinancialswidget .most-recent").text[/[0-9,]+/]
    puts c[0] + " - " + cash
  rescue 
    puts c[0] + " - " + "Not found" unless c[0].nil?
  end
  sleep 2 # 2 seconds between requests so as not to kill Duedil's servers
end
