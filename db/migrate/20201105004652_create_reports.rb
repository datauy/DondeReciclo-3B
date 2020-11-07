class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.references :sub_program, foreign_key: true
      t.string :subject
      t.text :comment
      t.references :country, null: false, foreign_key: true
      t.string :neighborhood
      t.string :address
      t.integer :weight
      t.boolean :donation

      t.timestamps
    end
  end
end
