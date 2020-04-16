class Supporter < ApplicationRecord
  has_one_attached :logo
  belongs_to :program
end
