class Zone < ApplicationRecord
  has_one_attached :icon_first
  has_one_attached :icon_second

  belongs_to :sub_program
  belongs_to :location, optional: true
  belongs_to :route, optional: true
  has_and_belongs_to_many :schedules

  enum pick_up_type: [
    'pick_up',
    'take_out',
    'deposit'
  ]
end
