class AddSenderIdToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :sender_id, :string
  end
end
