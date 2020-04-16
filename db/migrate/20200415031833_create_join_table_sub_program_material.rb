class CreateJoinTableSubProgramMaterial < ActiveRecord::Migration[6.0]
  def change
    create_join_table :subprograms, :materials do |t|
      # t.index [:subprogram_id, :material_id]
      # t.index [:material_id, :subprogram_id]
    end
  end
end
