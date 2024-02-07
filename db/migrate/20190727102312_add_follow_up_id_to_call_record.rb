class AddFollowUpIdToCallRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :call_records, :follow_up_id, :integer
  end
end
