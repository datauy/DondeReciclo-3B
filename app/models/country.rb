class Country < ApplicationRecord
  has_many :users

  has_many :dimension_relations
  has_many :dimensions, through: :dimension_relations

  has_many :predefined_searches
end
