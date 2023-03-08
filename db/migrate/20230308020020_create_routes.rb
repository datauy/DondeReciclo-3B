class CreateRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :routes do |t|
      t.string :name
      t.string :code
      t.multi_line_string :route, srid: 4326, null: false,
      t.timestamps
    end
  end
end
