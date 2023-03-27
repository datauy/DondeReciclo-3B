class Schedule < ApplicationRecord
  has_and_belongs_to_many :zones

  enum weekday: [
    'Todos',
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
    'Días hábiles'
  ]

  def formated_str
    "#{self.weekday}: #{self.start.strftime("%H:%M")} - #{self.end.strftime("%H:%M")}"
  end
  validates :weekday, :presence => true
end
