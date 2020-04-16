class CreatePrograms < ActiveRecord::Migration[6.0]
  def change
    create_table :programs do |t|
      t.string :name
      t.text :responsable
      t.string :responsable_url
      t.string :more_info
      t.text :reception_conditions
      t.string :contact
      t.text :information
      t.text :benefits
      t.text :lifecycle
      t.references :materials, null: false, foreign_key: true
      t.text :receives
      t.text :receives_no

      t.timestamps
    end
  end
end
