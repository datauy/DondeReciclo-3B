class AddCoordsToReport < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :coords, :st_point
  end
end
