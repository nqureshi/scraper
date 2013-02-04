require 'Nokogiri'
require 'open-uri'
require 'csv'
require 'companies_house'

## NOTE - THIS WHOLE SCRIPT ASSUMES A CSV FILE WITH A SINGLE COLUMN OF COMPANY NUMBERS. ANYTHING ELSE WILL FAIL 
## UNLESS YOU ALTER THE MAIN BIT

@reg = []

# Read company reg numbers from a CSV
CSV.foreach(File.join(File.dirname(__FILE__), 'Jan.csv')) do |row|
  @reg << row
end

data = @reg.map { |r| { reg: r } }

data.each do |company|
  begin
    url = "https://www.duedil.com/company/#{company[:reg][0]}/"
    c = CompaniesHouse.lookup company[:reg][0]
    company[:name] = c["CompanyName"]
    company[:sic_code] = c.sic_code
    company[:inc_date] = c["IncorporationDate"]
    company[:last_made_up_date] = c["Returns"]["LastMadeUpDate"]
    page = Nokogiri::HTML(open(url))
    cash = page.css("#widget_headlinefinancialswidget .most-recent").text[/[0-9,]+/]
    company[:cash] = cash
  rescue Exception => e
    puts e
  end
  puts "Done!"
end

CSV.open("/Users/nabeelqureshi/GoCardless Docs/activation/scraper/companydata.csv", "wb") do |csv|
  data.each do |a| 
    begin
      csv << [a[:reg], a[:name], a[:sic_code], a[:inc_date], a[:last_made_up_date], a[:cash]]
    rescue Exception => e
      puts e
    end
  end
end