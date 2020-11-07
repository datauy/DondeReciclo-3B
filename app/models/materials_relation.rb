class MaterialsRelation < ApplicationRecord
  belongs_to :material
  belongs_to :predefined_search, optional: true
  belongs_to :search, optional: true
  belongs_to :report, optional: true
end
