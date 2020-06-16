class WastesRelation < ApplicationRecord
  belongs_to :waste
  belongs_to :predefined_search
end
