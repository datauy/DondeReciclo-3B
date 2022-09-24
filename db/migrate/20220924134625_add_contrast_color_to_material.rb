class AddContrastColorToMaterial < ActiveRecord::Migration[6.0]
  def change
    add_column :materials, :contrast_color, :string
  end
end
