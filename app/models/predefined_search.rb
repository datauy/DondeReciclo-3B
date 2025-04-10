class PredefinedSearch < ApplicationRecord
  belongs_to :country
  belongs_to :dimension

  has_many :materials_relations
  has_many :materials, through: :materials_relations

  has_many :wastes_relations
  has_many :wastes, through: :wastes_relations

end
