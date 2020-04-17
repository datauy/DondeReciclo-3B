class CreateJoinTableContainersSchedules < ActiveRecord::Migration[6.0]
  def change
    create_join_table :containers, :schedules do |t|
      t.index [:container_id, :schedule_id]
      # t.index [:schedule_id, :container_id]
    end
  end
end
