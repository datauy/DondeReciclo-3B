class AddContactEmailToCountries < ActiveRecord::Migration[6.0]
  def change
    add_column :countries, :contact, :string
  end
end
