class CreateNews < ActiveRecord::Migration[6.0]
  def change
    create_table :news do |t|
      t.string :title
      t.text :information
      t.string :video

      t.timestamps
    end
  end
end
