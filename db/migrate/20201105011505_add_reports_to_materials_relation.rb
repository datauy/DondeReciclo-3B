class AddReportsToMaterialsRelation < ActiveRecord::Migration[6.0]
  def change
    add_reference :materials_relations, :report, foreign_key: true
  end
end
