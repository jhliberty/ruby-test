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
  entry[:dma]   = ask("City?  ") { |q| q.default = "none" }
  entry[:updated_dma] = ask("Updated City Name?  ") { |q| q.default = "" }
  
  puts entry
  
  choices = %w{yes no}
  say("Would you like to rename city? [yes] [no]")
  
  case ask("?  ", choices)
  when "yes"
    @loc = Location.where(:state => entry[:state], :dma => entry[:dma])
    if @loc.count === 0
      puts "no city found with name #{entry[:dma]}"
      updates << "no city found with name #{entry[:dma]}"
    elsif @loc.count === 1
      @loc.update_attributes(:dma => entry[:updated_dma])
      @loc = Location.where(:state => entry[:state], :dma => entry[:updated_dma])
      puts "1 Location updated with #{@loc.state} and #{@loc.dma}"
      updates << "1 Location updated with #{@loc.state} and #{@loc.dma}"
    else
      @loc.update_all(:dma => entry[:updated_dma])
      @loc = Location.where(:state => entry[:state], :dma => entry[:updated_dma])
      puts "#{@loc.count} records with state: #{@loc.state} have had their dma changed to #{@loc.dma}"
      updates << "#{@loc.count} records with state: #{@loc.state} have had their dma changed to #{@loc.dma}"
    end
  else
    @loc = Location.where(:state => entry[:state], :dma => entry[:dma])
    if @loc.empty?
      puts "No location found with #{entry[:state]} and #{entry[:dma]}"
      updates << "No location found with #{entry[:state]} and #{entry[:dma]}"
    else
      puts "#{@loc.count} records found, but not updated with #{entry[:state]} and #{entry[:dma]}"
      updates << "#{@loc.count} records found, but not updated with #{entry[:state]} and #{entry[:dma]}"
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