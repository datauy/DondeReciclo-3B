class Waste < ApplicationRecord
  has_one_attached :image
  belongs_to :material, optional: true
  has_and_belongs_to_many :products
  has_and_belongs_to_many :sub_programs

  def self.search(str)
    Waste.where("lower(name) like :value or lower(deposition) like :value", value: "%#{str}%")
  end
end
