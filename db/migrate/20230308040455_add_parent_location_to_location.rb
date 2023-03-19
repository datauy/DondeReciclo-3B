class AddParentLocationToLocation < ActiveRecord::Migration[6.0]
  def change
    add_reference :locations, :parent_location, foreign_key: { to_table: :locations }
  end
end
