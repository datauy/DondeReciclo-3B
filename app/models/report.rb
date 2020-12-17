class Report < ApplicationRecord
  belongs_to :sub_program, optional: true
  belongs_to :country

  has_many :materials_relations
  has_many :materials, through: :materials_relations

  has_many :wastes_relations
  has_many :wastes, through: :wastes_relations

end
