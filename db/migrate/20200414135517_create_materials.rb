class CreateMaterials < ActiveRecord::Migration[6.0]
  def change
    create_table :materials do |t|
      t.string :name
      t.text :information
      t.string :video
      t.string :color

      t.timestamps
    end
  end
end
