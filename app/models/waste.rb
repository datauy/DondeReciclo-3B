class Waste < ApplicationRecord
  has_one_attached :image
  belongs_to :material
  has_and_belongs_to_many :products
end
