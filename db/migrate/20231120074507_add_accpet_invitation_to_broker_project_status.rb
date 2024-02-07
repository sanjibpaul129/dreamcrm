class AddAccpetInvitationToBrokerProjectStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_project_statuses, :accpet_invitation, :boolean
  end
end
