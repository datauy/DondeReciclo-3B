class AddDimensionToPredefinedSearch < ActiveRecord::Migration[6.0]
  def change
    add_reference :predefined_searches, :dimension, null: false, foreign_key: true, default: 1
  end
end
