class RemoveAccpetInvitationFromBrokerProjectStatus < ActiveRecord::Migration[5.2]
  def change
    remove_column :broker_project_statuses, :accpet_invitation, :boolean
  end
end
