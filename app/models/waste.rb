class Waste < ApplicationRecord
  has_one_attached :icon
  belongs_to :material
  has_and_belongs_to_many :products
  has_and_belongs_to_many :sub_programs

  has_many :wastes_relations
  has_many :predefined_searches, through: :wastes_relations
  has_many :reports, through: :wastes_relations
  #has_many :searches, through: :wastes_relations

  has_many :material_relations, through: :material
  has_many :dimensions, through: :material_relations


  translates :name, :deposition

  scope :search_translations, ->(str) { where("lower(waste_translations.name) like :value or lower(waste_translations.deposition) like :value", value: "%#{str.strip.downcase}%") }

  def self.search(str, dimensions = nil)
    if dimensions.nil?
      Waste.with_translations.search_translations(str)
    else
      Waste.
      joins(material: :materials_relations).
      with_translations.
      search_translations(str).
      where("materials_relations.dimension_id": dimensions)
    end
  end
  def self.search_name(str)
    Waste.with_translations.where("lower(waste_translations.name) = :value", value: "#{str.strip.downcase}")
  end
end
