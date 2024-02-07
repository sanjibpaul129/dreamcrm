class AddScheduledTimeToFollowUps < ActiveRecord::Migration[5.2]
  def change
  add_column :follow_ups, :scheduled_time, :datetime
  end
end
