class WastesRelation < ApplicationRecord
  belongs_to :waste
  belongs_to :predefined_search, optional: true
  belongs_to :search, optional: true
  belongs_to :report, optional: true
end
