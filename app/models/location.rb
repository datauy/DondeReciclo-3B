class Location < ApplicationRecord
  has_one_attached :file

  has_many :location_relations
  has_many :sub_programs, through: :location_relations

  has_many :zones
end
