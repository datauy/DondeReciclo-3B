class Zone < ApplicationRecord
  belongs_to :sub_program
  belongs_to :location
  has_and_belongs_to_many :schedules

  enum pick_up_type: [
    'pick_up',
    'take_out',
    'deposit'
  ]
end
