class AddPersonnelIdToCallRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :call_records, :personnel_id, :integer
  end
end
