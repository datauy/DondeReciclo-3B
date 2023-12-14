class Location < ApplicationRecord
  has_one_attached :file

  has_many :location_relations
  has_many :sub_programs, through: :location_relations
  belongs_to :parent_location, class_name: 'Location'

  has_many :zones

  enum loc_type: [
    'country',
    'state',
    'city',
    'municipality',
    'neighborhood',
    'area'
  ]
end
