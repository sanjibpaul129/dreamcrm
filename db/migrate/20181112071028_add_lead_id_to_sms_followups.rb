class AddLeadIdToSmsFollowups < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_followups, :lead_id, :integer
  end
end
