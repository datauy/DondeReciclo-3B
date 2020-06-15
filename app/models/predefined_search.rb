class PredefinedSearch < ApplicationRecord
  belongs_to :country
  has_many :materials_relations
  has_many :materials, through: :materials_relations
  #accepts_nested_attributes_for :materials_relations, allow_destroy: true

end
