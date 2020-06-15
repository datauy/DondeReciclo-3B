class CreateMaterialsRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :materials_relations do |t|
      t.references :material, null: false, foreign_key: true
      t.references :predefined_search, foreign_key: true

      t.timestamps
    end
  end
end
