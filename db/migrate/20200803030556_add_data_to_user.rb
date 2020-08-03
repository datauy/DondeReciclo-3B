class AddDataToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :sex, :string
    add_column :users, :state, :string
    add_column :users, :neighborhood, :string
    add_column :users, :age, :integer
  end
end
