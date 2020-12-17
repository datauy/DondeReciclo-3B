class RemovePredefinedSearchColumnFromWastes < ActiveRecord::Migration[6.0]
  def change
    remove_column :wastes, :predefined_search
  end
end
