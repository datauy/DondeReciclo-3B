class AddActionsToSubProgram < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_programs, :action_link, :string
    add_column :sub_programs, :action_title, :string
  end
end
