class Material < ApplicationRecord
  has_one_attached :image

  has_and_belongs_to_many :sub_programs
  accepts_nested_attributes_for :sub_programs
end
