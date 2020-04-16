class AddProgramToSupporters < ActiveRecord::Migration[6.0]
  def change
    add_reference :supporters, :program, null: false, foreign_key: true
  end
end
