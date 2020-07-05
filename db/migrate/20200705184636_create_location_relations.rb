class CreateLocationRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :location_relations do |t|
      t.references :location, null: false, foreign_key: true
      t.references :program, foreign_key: true
      t.references :sub_program, foreign_key: true

      t.timestamps
    end
  end
end
