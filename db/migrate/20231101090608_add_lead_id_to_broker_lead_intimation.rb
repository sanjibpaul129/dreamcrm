class AddLeadIdToBrokerLeadIntimation < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_lead_intimations, :lead_id, :integer
  end
end
