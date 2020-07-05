class LocationRelation < ApplicationRecord
  belongs_to :location
  belongs_to :program, optional: true
  belongs_to :sub_program, optional: true
end
