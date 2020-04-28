class SubProgram < ApplicationRecord
  has_many_attached :zones
  belongs_to :program

  has_and_belongs_to_many :materials
  accepts_nested_attributes_for :materials, :allow_destroy => false
  has_and_belongs_to_many :wastes
  accepts_nested_attributes_for :wastes, :allow_destroy => false
end
