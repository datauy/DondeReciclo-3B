class AddInformationToZone < ActiveRecord::Migration[6.0]
  def change
    add_column :zones, :information, :text
  end
end
