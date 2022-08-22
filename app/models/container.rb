class Container < ApplicationRecord

  belongs_to :sub_program
  belongs_to :container_type
  has_and_belongs_to_many :schedules
  accepts_nested_attributes_for :schedules, :allow_destroy => true
  #has_many :materials, :through => :sub_program
  has_one :program, through: :sub_program
  has_one :country, through: :program

  has_one_attached :custom_icon
  has_many_attached :photos
  geocoded_by latitude: :lat, longitude: :lon

  scope :close_to, ->(lat, lon) {
    select("*").
    select(sanitize_sql_array( [
      "ST_Distance(:point::geometry, ST_SetSRID( ST_Point( containers.latitude, containers.longitude), 4326)) as distance",
      point: "SRID=4326;POINT(#{lat} #{lon})"] )).
    where( "ST_Distance(:point::geometry, ST_SetSRID( ST_Point( containers.latitude, containers.longitude), 4326)) < 6", point: "SRID=4326;POINT(#{lat} #{lon})" ).
    order(distance: :asc)
  }

  def custom_icon_url
    self.custom_icon.attached? && self.custom_icon_active ? url_for(self.custom_icon) : ''
  end
end
