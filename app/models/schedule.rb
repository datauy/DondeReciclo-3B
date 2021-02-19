class Schedule < ApplicationRecord
  has_and_belongs_to_many :zones

  enum weekdays: [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo'
  ]

  def formated_str
    "#{self.weekday}: #{self.start.strftime("%H:%M")} - #{self.end.strftime("%H:%M")}"
  end
  
end
