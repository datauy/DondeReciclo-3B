class AddFieldsToSubProgram < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_programs, :city, :string
    add_column :sub_programs, :address, :string
    add_column :sub_programs, :email, :string
    add_column :sub_programs, :phone, :string
    add_column :sub_programs, :full_name, :string
  end
end
