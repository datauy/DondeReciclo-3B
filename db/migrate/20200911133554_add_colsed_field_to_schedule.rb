class AddColsedFieldToSchedule < ActiveRecord::Migration[6.0]
  def change
    add_column :schedules, :closed, :boolean
  end
end
