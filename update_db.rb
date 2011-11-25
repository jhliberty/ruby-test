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
  entry[:updated_region] = ask("Updated City Name?  ") { |q| q.default = "" }
  
  puts entry
  @loc = Location.where(:state => entry[:state], :region => entry[:region])
  
  
  choices = %w{yes no}
  say("Would you like to rename city? [yes] [no]")
  
  case ask("?  ", choices)
  when "yes"
    @loc = Location.where(:state => entry[:state], :region => entry[:region])
    if @loc.count === 0
      puts "no city found with name #{entry[:region]}"
      updates << "no city found with name #{entry[:region]}"
    else
      @loc.update_all(:region => entry[:updated_region])
      @loc = Location.where(:state => entry[:state], :region => entry[:updated_region])
      puts "#{@loc.count} records with state: #{entry[:state]} have had their region changed to #{entry[:updated_region]}"
      updates << "#{@loc.count} records with state: #{entry[:state]} have had their region changed to #{entry[:updated_region]}"
    end
  else
    @loc = Location.where(:state => entry[:state], :region => entry[:region])
    if @loc.empty?
      puts "No location found with #{entry[:state]} and #{entry[:region]}"
      updates << "No location found with #{entry[:state]} and #{entry[:region]}"
    else
      puts "#{@loc.count} records found, but not updated with #{entry[:state]} and #{entry[:region]}"
      updates << "#{@loc.count} records found, but not updated with #{entry[:state]} and #{entry[:region]}"
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

  # if agree("Save these contacts?  ", true)
  #   file_name = ask("Enter a file name:  ") do |q|
  #     q.validate = /\A\w+\Z/
  #     q.confirm  = true
  #   end
  #   File.open("#{file_name}.yaml", "w") { |file| YAML.dump(contacts, file) }
  # end
  
  # def rename_city(state, dma, updated_dma)
  #   @loc = Location.where(:state => state, :dma => dma)
  #   if @loc.empty?
  #     puts "nothing here, capn"
  #   else
  #     @loc.update_all(:dma => updated_dma)
  #     @loc = Location.where(:state => state, :dma => updated_dma)
  #     if @loc.empty?
  #       puts "update failed"
  #     else
  #       puts "updated successfully"
  #     end
  #   end
  # end
  
    # rename_city("alabama", "jacksons gap", "jackson's gap")