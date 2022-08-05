class AddDetailsToLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :loc_type, :integer
    add_column :locations, :code, :string
  end
end
