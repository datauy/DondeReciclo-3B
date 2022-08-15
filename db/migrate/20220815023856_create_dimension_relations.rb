class CreateDimensionRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :dimension_relations do |t|
      t.references :dimension, null: false, foreign_key: true
      t.references :country, foreign_key: true

      t.timestamps
    end
  end
end
