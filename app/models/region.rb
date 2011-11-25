class Region < ActiveRecord::Base
  belongs_to :dma, :foreign_key => "dma_id"
  has_one :location
end
