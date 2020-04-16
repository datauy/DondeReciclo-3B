class CreateContainers < ActiveRecord::Migration[6.0]
  def change
    create_table :containers do |t|
      t.references :sub_program, null: false, foreign_key: true
      t.string :external_id
      t.decimal :lat
      t.decimal :long
      t.string :site
      t.string :address
      t.string :location
      t.string :state
      t.string :site_type
      t.boolean :public_site
      t.references :container_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
