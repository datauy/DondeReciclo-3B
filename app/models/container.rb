class Container < ApplicationRecord
  belongs_to :sub_program
  belongs_to :container_type
  has_and_belongs_to_many :schedules
  accepts_nested_attributes_for :schedules, :allow_destroy => true
  #has_many :materials, :through => :sub_program

  has_many_attached :photos
  geocoded_by latitude: :lat, longitude: :lon
end
