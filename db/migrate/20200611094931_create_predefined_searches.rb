class CreatePredefinedSearches < ActiveRecord::Migration[6.0]
  def change
    create_table :predefined_searches do |t|
      t.references :country, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
