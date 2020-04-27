class AddShortNameToPrograms < ActiveRecord::Migration[6.0]
  def change
    add_column :programs, :shortname, :string
  end
end
