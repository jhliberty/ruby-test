class Location < ActiveRecord::Base
  has_many :states
  has_many :dmas
  has_many :regions
  
  attr_accessible :region
end
