class RemovePredefinedSearchColumnFromMaterials < ActiveRecord::Migration[6.0]
  def change

    remove_column :materials, :predefined_search
  end
end
