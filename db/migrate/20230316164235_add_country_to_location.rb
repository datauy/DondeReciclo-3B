class AddCountryToLocation < ActiveRecord::Migration[6.0]
  def change
    add_reference :locations, :country, null: false, foreign_key: true, default: 2
  end
end
