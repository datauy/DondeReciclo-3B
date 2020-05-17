class Container < ApplicationRecord
  belongs_to :sub_program
  belongs_to :container_type

  has_one_attached :photos
  geocoded_by latitude: :lat, longitude: :lon
end
