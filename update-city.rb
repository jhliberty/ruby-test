require "rubygems"
require "highline/import"
require "yaml"
require "active_record"
require "mysql2"
require "csv"

@environment = ENV['RACK_ENV'] || 'development'
@dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection @dbconfig[@environment]

#Load All models 
Dir.glob("./app/models/*").each do |file|
  require file 
end
  
    updates = [ ]

begin 
  entry = Hash.new
  entry[:csv] = ask("Which CSV file would you like to use?  ")
  
  CSV.foreach("#{entry[:csv]}.csv", {:headers => true, :return_headers => false, :header_converters => :symbol, :converters => :all}) do |row|
    @loc = Location.where(:state => row[:state], :region => row[:region]).first
    if @loc.nil?
      puts "No record found with #{row[:state]} and #{row[:region]}"
    else
      @region = Region.where(:state_id => @loc.state_id, :region => @loc.region)
      if @region.nil?
        message = "No region matches #{@loc.region} and #{@loc.state}"
      else
        @region.update_all(:region => row[:updated_region])
        @region = Region.where(:region => row[:updated_region], :state_id => @loc.state_id)
        message = "#{@region.count} regions updated with #{@loc.state} and #{row[:updated_region]}"
        puts message
        updates << message
      end
    end
  end
end

if agree("Save these updates?  ", true)
  file_name = ask("Enter a file name:  ") do |q|
    q.validate = /\A\w+\Z/
    # q.confirm  = true
  end
  File.open("#{file_name}.yaml", "w") { |file| YAML.dump(updates, file) }
end

