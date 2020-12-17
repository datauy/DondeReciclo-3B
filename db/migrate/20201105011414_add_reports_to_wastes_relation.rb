class AddReportsToWastesRelation < ActiveRecord::Migration[6.0]
  def change
    add_reference :wastes_relations, :report, foreign_key: true
  end
end
