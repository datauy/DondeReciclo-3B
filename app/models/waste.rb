class Waste < ApplicationRecord
  has_one_attached :icon
  belongs_to :material
  has_and_belongs_to_many :products
  has_and_belongs_to_many :sub_programs

  has_many :wastes_relations
  has_many :predefined_searches, through: :wastes_relations
  has_many :reports, through: :wastes_relations
  #has_many :searches, through: :wastes_relations

  translates :name, :deposition

  def self.search(str, dimension = nil)
    if dimension.nil?
      Waste.with_translations.where("lower(waste_translations.name) like :value or lower(waste_translations.deposition) like :value", value: "%#{str.strip.downcase}%")
    else
      Waste.joins(:material).with_translations.where("( lower(waste_translations.name) like :value or lower(waste_translations.deposition) like :value )
      #{ dimension.nil? ? '' : ' and materials.dimension_id = :dimension'}",
      { value: "%#{str.strip.downcase}%", dimension: dimension } )
    end
  end
  def self.search_name(str)
    Waste.with_translations.where("lower(waste_translations.name) = :value", value: "#{str.strip.downcase}")
  end
end
