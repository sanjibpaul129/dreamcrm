class RemoveLeadNameFromCallRecords < ActiveRecord::Migration[5.2]
  def change
  	remove_column :call_records, :lead_name
  end
end
