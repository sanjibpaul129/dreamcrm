class AddLeadIdToEmailFollowups < ActiveRecord::Migration[5.2]
  def change
    add_column :email_followups, :lead_id, :integer
  end
end
