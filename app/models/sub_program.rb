class SubProgram < ApplicationRecord
  has_many_attached :zones
  belongs_to :program
  belongs_to :material
  has_many :containers

  has_and_belongs_to_many :materials #, primary_key: [:material_id, :sub_program_id]
  accepts_nested_attributes_for :materials, :allow_destroy => false

  has_and_belongs_to_many :wastes
  accepts_nested_attributes_for :wastes, :allow_destroy => false

  class HABTM_Materials
    self.primary_key = :material_id
  end
end
