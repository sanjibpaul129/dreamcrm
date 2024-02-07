class AddRemarksToBrokerLeadIntimation < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_lead_intimations, :remarks, :text
  end
end
