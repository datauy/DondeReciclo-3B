class CreateJoinTableUserSubProgram < ActiveRecord::Migration[6.0]
  def change
    create_join_table :users, :sub_programs do |t|
      t.index [:user_id, :sub_program_id]
      # t.index [:sub_program_id, :user_id]
    end
  end
end
