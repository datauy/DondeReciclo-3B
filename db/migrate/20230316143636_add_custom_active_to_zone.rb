class AddCustomActiveToZone < ActiveRecord::Migration[6.0]
  def change
    add_column :zones, :custom_active, :boolean
  end
end
