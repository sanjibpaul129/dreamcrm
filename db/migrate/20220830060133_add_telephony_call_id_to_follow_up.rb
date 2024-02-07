class AddTelephonyCallIdToFollowUp < ActiveRecord::Migration[5.2]
  def change
    add_column :follow_ups, :telephony_call_id, :integer
  end
end
