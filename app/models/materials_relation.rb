class MaterialsRelation < ApplicationRecord
  belongs_to :material
  belongs_to :predefined_search
end
