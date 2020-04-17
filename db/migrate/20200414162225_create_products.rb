class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :information
      t.string :video
      t.integer :barcode

      t.timestamps
    end
    #add_index :products, :barcode, unique: true
  end
end
