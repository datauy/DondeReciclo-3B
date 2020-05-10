class AddPredefinedSearchToMaterials < ActiveRecord::Migration[6.0]
  def change
    add_column :materials, :predefined_search, :boolean
  end
end
