class AddRouteToZone < ActiveRecord::Migration[6.0]
  def change
    add_reference :zones, :route, foreign_key: true
  end
end
