class CreateJoinTableZoneSchedules < ActiveRecord::Migration[6.0]
  def change
    create_join_table :zones, :schedules do |t|
      t.index [:zone_id, :schedule_id]
      # t.index [:schedule_id, :zone_id]
    end
  end
end
