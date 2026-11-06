class AddSpatialAndFilterIndexesToContainers < ActiveRecord::Migration[6.0]
  # The expression index is derived from latitude/longitude, so it can never go
  # out of sync with them (unlike the optional latlon column).
  def up
    execute <<~SQL
      CREATE INDEX index_containers_on_point_gist ON containers
      USING gist (ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326))
    SQL
    add_index :materials_sub_programs, :material_id
    add_index :sub_programs_wastes, :waste_id
  end

  def down
    remove_index :sub_programs_wastes, :waste_id
    remove_index :materials_sub_programs, :material_id
    execute 'DROP INDEX index_containers_on_point_gist'
  end
end
