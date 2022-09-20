class TagRelation < ApplicationRecord
  belongs_to :tag
  belongs_to :program, optional: true
end
