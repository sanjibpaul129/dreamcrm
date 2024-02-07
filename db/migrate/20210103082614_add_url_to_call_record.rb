class AddUrlToCallRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :call_records, :url, :string
  end
end
