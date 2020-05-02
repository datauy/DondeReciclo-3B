class Material < ApplicationRecord
  has_one_attached :image

  has_and_belongs_to_many :sub_programs
  accepts_nested_attributes_for :sub_programs

  def self.search(str)
    Material.where("lower(name) like :value or lower(information) like :value", value: "%#{str}%")
  end
end
