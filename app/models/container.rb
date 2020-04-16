class Container < ApplicationRecord
  belongs_to :sub_program
  belongs_to :container_type
end
