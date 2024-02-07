class AddFollowUpMadeToCallRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :call_records, :follow_up_made, :boolean
  end
end
