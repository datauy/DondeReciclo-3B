class Material < ApplicationRecord
  has_and_belongs_to_many :sub_programs#, set_primary_key: [:material_id, :sub_program_id]
  has_one_attached :icon
  #has_many :subprogram_materials
  #has_many :sub_programs, through: :subprogram_materials

  accepts_nested_attributes_for :sub_programs

  def self.search(str)
    Material.where("lower(name) like :value or lower(information) like :value", value: "%#{str}%")
  end
end
