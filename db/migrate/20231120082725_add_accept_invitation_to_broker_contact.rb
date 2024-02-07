class AddAcceptInvitationToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :accept_invitation, :boolean
  end
end
