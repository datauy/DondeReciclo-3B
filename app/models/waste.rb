class Waste < ApplicationRecord
  has_one_attached :image
  belongs_to :material, optional: true
  has_and_belongs_to_many :products
  has_and_belongs_to_many :sub_programs

  has_many :wastes_relations
  has_many :predefined_searches, through: :wastes_relations

  def self.search(str)
    Waste.where("lower(name) like :value or lower(deposition) like :value", value: "%#{str}%")
  end
end
