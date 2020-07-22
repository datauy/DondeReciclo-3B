class Material < ApplicationRecord
  has_and_belongs_to_many :sub_programs#, set_primary_key: [:material_id, :sub_program_id]
  has_one_attached :icon
  has_many :materials_relations
  has_many :predefined_searches, through: :materials_relations

  accepts_nested_attributes_for :sub_programs

  attr_accessor :name_class

  def self.search(str)
    Material.where("lower(name) like :value or lower(information) like :value", value: "%#{str}%")
  end
  def name_class
    self.name.downcase.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').gsub(/\s/,'-')
  end
end
