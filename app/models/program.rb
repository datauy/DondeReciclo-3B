class Program < ApplicationRecord
  has_one_attached :logo
  has_and_belongs_to_many :materials
  has_many :supporters
end
