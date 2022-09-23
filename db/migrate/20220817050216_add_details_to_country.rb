class AddDetailsToCountry < ActiveRecord::Migration[6.0]
  def change
    add_column :countries, :code, :string
    add_column :countries, :locale, :string
    add_column :countries, :lat, :numeric
    add_column :countries, :lon, :numeric
  end
end
