class CreateZones < ActiveRecord::Migration[6.0]
  def change
    create_table :zones do |t|
      t.references :sub_program, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.boolean :is_route
      t.integer :pick_up_type

      t.timestamps
    end
  end
end
