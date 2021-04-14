class AddMaterialWasteTranslations < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        Material.create_translation_table!({
            :name => :string,
            :information => :text
          }, {
            :migrate_data => true
          }
        )
        Waste.create_translation_table!({
          :name => :string,
          :deposition => :text
          }, {
            :migrate_data => true
          }
        )
      end

      dir.down do
        Material.drop_translation_table! :migrate_data => true
        Waste.drop_translation_table! :migrate_data => true
      end
    end
  end
end
