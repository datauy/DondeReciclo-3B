class Zone < ApplicationRecord
  has_one_attached :icon_start
  has_one_attached :icon_end

  belongs_to :sub_program
  belongs_to :location, optional: true
  belongs_to :route, optional: true
  has_and_belongs_to_many :schedules
  accepts_nested_attributes_for :schedules, :allow_destroy => true

  enum pick_up_type: [
    'pick_up',
    'take_out',
    'deposit'
  ]
  # TODO: CORREGIR
  #class HABTM_Schedules
  #  self.primary_key = :id
  #end
end
