class AddGPointToContainers < ActiveRecord::Migration[6.0]
  def change
    add_column :containers, :latlon, :st_point, :geographic => true
  end
end
