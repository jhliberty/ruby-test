class Dma < ActiveRecord::Base
  has_many :regions, :foreign_key => "dma_id"
  belongs_to :location
end
