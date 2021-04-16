class AddCountryToAdminUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :admin_users, :country, foreign_key: true
  end
end
