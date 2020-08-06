class AddHiddenToContainer < ActiveRecord::Migration[6.0]
  def change
    add_column :containers, :hidden, :boolean, :default => false
  end
end
