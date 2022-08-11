class CreateDimensions < ActiveRecord::Migration[6.0]
  def change
    create_table :dimensions do |t|
      t.string :name
      t.text :information
      t.string :color

      t.timestamps
    end
  end
end
