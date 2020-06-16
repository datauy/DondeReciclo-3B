class AddMainMaterialToSubProgram < ActiveRecord::Migration[6.0]
  def change
    add_reference :sub_programs, :material, null: false, default: 1, foreign_key: true
  end
end
