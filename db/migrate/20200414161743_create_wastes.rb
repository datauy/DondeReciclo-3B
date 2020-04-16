class CreateWastes < ActiveRecord::Migration[6.0]
  def change
    create_table :wastes do |t|
      t.references :material, null: false, foreign_key: true
      t.string :name
      t.text :deposition

      t.timestamps
    end
  end
end
