class AddLeadIdToCallRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :call_records, :lead_id, :integer
  end
end
