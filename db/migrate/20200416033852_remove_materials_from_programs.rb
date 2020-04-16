class RemoveMaterialsFromPrograms < ActiveRecord::Migration[6.0]
  def change
    remove_reference :programs, :materials, null: false, foreign_key: true
  end
end
