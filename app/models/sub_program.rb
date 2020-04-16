class SubProgram < ApplicationRecord
  has_many_attached :zones
  belongs_to :program
  has_and_belongs_to_many :materials
end
