class CreateSubPrograms < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_programs do |t|
      t.references :program, null: false, foreign_key: true
      t.string :name
      t.text :reception_conditions
      t.text :receives
      t.text :receives_no

      t.timestamps
    end
  end
end
