class Route < ApplicationRecord

  has_many: :route_relations
  has_many: :zones, through: :route_relations
  
end
