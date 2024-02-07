class AddLeadNameToCallRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :call_records, :lead_name, :string
  end
end
