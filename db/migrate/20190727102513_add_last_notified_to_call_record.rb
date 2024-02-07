class AddLastNotifiedToCallRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :call_records, :last_notified, :boolean
  end
end
