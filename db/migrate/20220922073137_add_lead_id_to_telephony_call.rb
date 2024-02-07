class AddLeadIdToTelephonyCall < ActiveRecord::Migration[5.2]
  def change
    add_column :telephony_calls, :lead_id, :integer
  end
end
