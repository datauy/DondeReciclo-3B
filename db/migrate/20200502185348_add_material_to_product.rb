class AddMaterialToProduct < ActiveRecord::Migration[6.0]
  def change
    add_reference :products, :material, null: false, foreign_key: true
  end
end
