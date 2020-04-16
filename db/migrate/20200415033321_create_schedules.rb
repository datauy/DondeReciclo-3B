class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.integer :weekday
      t.time :start
      t.time :end
      t.string :desc

      t.timestamps
    end
  end
end
