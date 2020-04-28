class ChangeContainersGeoColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :containers, :lat, :latitude
    rename_column :containers, :long, :longitude
    add_index :containers, [:latitude, :longitude]
  end
end
