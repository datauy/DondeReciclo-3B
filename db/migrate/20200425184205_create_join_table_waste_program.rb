class CreateJoinTableWasteProgram < ActiveRecord::Migration[6.0]
  def change
    create_join_table :wastes, :programs do |t|
      # t.index [:waste_id, :program_id]
      t.index [:program_id, :waste_id]
    end
  end
end
