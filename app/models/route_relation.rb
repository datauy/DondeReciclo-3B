class RouteRelation < ApplicationRecord
  belongs_to :route
  belongs_to :zone
end
