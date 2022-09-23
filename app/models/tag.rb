class Tag < ApplicationRecord
  has_many :tag_relations
  has_many :programs, through: :tag_relations

  enum section: [
    'programas',
    'contenedores',
  ]
end
