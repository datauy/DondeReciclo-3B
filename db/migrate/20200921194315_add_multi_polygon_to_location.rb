class AddMultiPolygonToLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :geometry, :multi_polygon
  end
end
