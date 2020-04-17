class CreateJoinTableSubProgramMaterial < ActiveRecord::Migration[6.0]
  def change
    create_join_table :sub_programs, :materials do |t|
      t.index [:sub_program_id, :material_id]
      # t.index [:material_id, :sub_program_id]
    end
  end
end
