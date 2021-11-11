class AddCustomIconActiveToContainer < ActiveRecord::Migration[6.0]
  def change
    add_column :containers, :custom_icon_active, :boolean
  end
end
