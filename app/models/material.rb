class Material < ApplicationRecord
  has_and_belongs_to_many :sub_programs#, set_primary_key: [:material_id, :sub_program_id]
  has_one_attached :icon

  has_many :wastes
  has_many :materials_relations
  has_many :predefined_searches, through: :materials_relations
  has_many :reports, through: :materials_relations
  #has_many :searches, through: :materials_relations

  accepts_nested_attributes_for :sub_programs

  attr_accessor :name_class

  translates :name, :information

  def self.search(str)
    Material.with_translations.where("lower(material_translations.name) like :value or lower(material_translations.information) like :value", value: "%#{str.strip.downcase}%")
  end
  def self.search_name(str)
    Material.with_translations.where("lower(material_translations.name) = :value", value: "%#{str.strip.downcase}%")
  end
  def name_class
    lastLocale = I18n.locale
    I18n.locale = I18n.default_locale
    name_class = self.name.downcase.unicode_normalize(:nfkd).gsub(/[^\x00-\x7F]/n,'').gsub(/\s/,'-')
    I18n.locale = lastLocale
    return name_class
  end
  def children
    self.wastes
  end
end
