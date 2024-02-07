class AddBrokerContactIdToFollowUp < ActiveRecord::Migration[5.2]
  def change
    add_column :follow_ups, :broker_contact_id, :integer
  end
end
