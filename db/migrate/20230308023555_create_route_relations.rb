class CreateRouteRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :route_relations do |t|
      t.references :route, null: false, foreign_key: true
      t.references :zone, foreign_key: true

      t.timestamps
    end
  end
end
