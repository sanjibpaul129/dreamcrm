class CreateBrokerProjectStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :broker_project_statuses do |t|
      t.integer :broker_id
      t.integer :business_unit_id
      t.boolean :contacted
      t.boolean :softcopy_collaterals_sent
      t.boolean :hardcopy_collaterals_sent
      t.boolean :site_visited
      t.boolean :contract_signed

      t.timestamps null: false
    end
  end
end
