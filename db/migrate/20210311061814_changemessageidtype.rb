class Changemessageidtype < ActiveRecord::Migration[5.2]
  def change
  	change_column :bulk_recipients, :message_id, :string
  end
end
