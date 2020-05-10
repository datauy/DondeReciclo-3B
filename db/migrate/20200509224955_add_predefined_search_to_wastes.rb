class AddPredefinedSearchToWastes < ActiveRecord::Migration[6.0]
  def change
    add_column :wastes, :predefined_search, :boolean
  end
end
