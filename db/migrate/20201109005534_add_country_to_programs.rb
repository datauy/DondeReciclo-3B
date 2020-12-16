class AddCountryToPrograms < ActiveRecord::Migration[6.0]
  def change
    add_reference :programs, :country, null: false, foreign_key: true, default: 1
  end
end
