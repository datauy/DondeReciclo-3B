class AddDimensionToMaterial < ActiveRecord::Migration[6.0]
  def change
    add_reference :materials, :dimension, null: false, foreign_key: true, default: 1
  end
end
