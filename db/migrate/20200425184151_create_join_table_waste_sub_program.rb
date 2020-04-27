class CreateJoinTableWasteSubProgram < ActiveRecord::Migration[6.0]
  def change
    create_join_table :wastes, :sub_programs do |t|
      # t.index [:waste_id, :sub_program_id]
      t.index [:sub_program_id, :waste_id]
    end
  end
end
