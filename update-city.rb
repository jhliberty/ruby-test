require "rubygems"
require "highline/import"
require "yaml"
require "active_record"
require "mysql2"


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
  entry[:state] = ask("State?  ") { |q| q.default = "none" }
  entry[:region]   = ask("City?  ") { |q| q.default = "none" }
  
  
  puts entry
  
  @loc = Location.where(:state => entry[:state], :region => entry[:region])
  if @loc.empty?
    message = "No location found with #{entry[:state]} and #{entry[:region]}"
    puts message
    updates << message
  else
    puts "#{@loc.count} records found with #{entry[:state]} and #{entry[:region]}"
    choices = %w{yes no}
    say("Would you like to rename city? [yes] [no]")

    case ask("?  ", choices)
    when "yes"
      entry[:updated_region] = ask("Updated City Name?  ") { |q| q.default = "" }
      @loc.update_all(:region => entry[:updated_region])
      @loc = Location.where(:state => entry[:state], :region => entry[:updated_region])
      message = "#{@loc.count} records with state: #{entry[:state]} have had their region changed to #{entry[:updated_region]}"
      puts message
      updates << message
    else
      message = "#{@loc.count} records found, but not updated with #{entry[:state]} and #{entry[:region]}"
      puts message
      updates << message
    end    
  end
end while agree("Enter another update?  ", true)

  if agree("Save these updates?  ", true)
    file_name = ask("Enter a file name:  ") do |q|
      q.validate = /\A\w+\Z/
      # q.confirm  = true
    end
    File.open("#{file_name}.yaml", "w") { |file| YAML.dump(updates, file) }
  end
  
