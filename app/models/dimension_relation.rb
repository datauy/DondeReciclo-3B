class DimensionRelation < ApplicationRecord
  belongs_to :dimension
  belongs_to :country, optional: true
end
