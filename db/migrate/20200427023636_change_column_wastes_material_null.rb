class ChangeColumnWastesMaterialNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :wastes, :material_id, true
  end
end
