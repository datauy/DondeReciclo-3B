class AddCountryToNews < ActiveRecord::Migration[6.0]
  def change
    add_reference :news, :country, foreign_key: true
  end
end
