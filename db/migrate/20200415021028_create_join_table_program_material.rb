class CreateJoinTableProgramMaterial < ActiveRecord::Migration[6.0]
  def change
    create_join_table :programs, :materials do |t|
      t.index [:program_id, :material_id]
      # t.index [:material_id, :program_id]
    end
  end
end
