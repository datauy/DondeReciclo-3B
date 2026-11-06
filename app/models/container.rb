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
  POINT_SQL = 'ST_SetSRID(ST_MakePoint(containers.longitude::double precision, containers.latitude::double precision), 4326)'.freeze

  # Uses the GiST expression index; handles boxes crossing the antimeridian (west > east).
  scope :in_bbox, ->(sw, ne) {
    south, west = sw.map(&:to_f)
    north, east = ne.map(&:to_f)
    if west <= east
      where("#{POINT_SQL} && ST_MakeEnvelope(?, ?, ?, ?, 4326)", west, south, east, north)
    else
      where("(#{POINT_SQL} && ST_MakeEnvelope(?, ?, 180, ?, 4326) OR #{POINT_SQL} && ST_MakeEnvelope(-180, ?, ?, ?, 4326))",
            west, south, north, south, east, north)
    end
  }
  scope :from_state, ->(wkt) {
    where("ST_Contains( ST_SetSRID( ST_GeomFromText(:state), 4326), ST_SetSRID( ST_Point( containers.longitude, containers.latitude), 4326) ) = true", state: wkt)
  }

  def custom_icon_url
    self.custom_icon.attached? && self.custom_icon_active ? url_for(self.custom_icon) : ''
  end
end
