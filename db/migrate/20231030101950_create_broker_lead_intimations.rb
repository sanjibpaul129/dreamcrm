class CreateBrokerLeadIntimations < ActiveRecord::Migration[5.2]
  def change
    create_table :broker_lead_intimations do |t|
      t.integer :broker_contact_id
      t.integer :business_unit_id
      t.string :name
      t.string :email
      t.string :mobile

      t.timestamps null: false
    end
  end
end
