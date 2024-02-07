class AddInvitationReadToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :invitation_read, :boolean
  end
end
