class AddTagToProgram < ActiveRecord::Migration[6.0]
  def change
    add_reference :programs, :tag, foreign_key: true
  end
end
