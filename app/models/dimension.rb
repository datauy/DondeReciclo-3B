class Dimension < ApplicationRecord
  has_many :materials_relations
  has_many :predefined_searches
  has_many :dimension_relations
  has_many :countries, through: :dimension_relations
  has_many :materials, through: :materials_relations
  #accepts_nested_attributes_for :dimension_relation
end
