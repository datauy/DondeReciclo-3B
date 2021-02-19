class AddInformationToContainer < ActiveRecord::Migration[6.0]
  def change
    add_column :containers, :information, :text
  end
end
