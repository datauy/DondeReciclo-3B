class Product < ApplicationRecord
  has_one_attached :image
  has_and_belongs_to_many :wastes
  belongs_to :material

  def self.search(str)
    Product.where("lower(name) like :value or lower(information) like :value", value: "%#{str}%")
  end
end
