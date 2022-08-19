class Dimension < ApplicationRecord
  has_many :materials
  has_many :predefined_searches
  has_many :dimension_relations
  has_many :countries, through: :dimension_relations
  #accepts_nested_attributes_for :dimension_relation
end
