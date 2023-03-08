class AddColorToZone < ActiveRecord::Migration[6.0]
  def change
    add_column :zones, :color, :string
  end
end
