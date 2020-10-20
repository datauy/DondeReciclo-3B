class AddGeometryToCountries < ActiveRecord::Migration[6.0]
  def change
    add_column :countries, :geometry, :multi_polygon
  end
end
