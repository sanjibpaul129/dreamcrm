class CreateBrokerContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :broker_contacts do |t|
      t.string :name
      t.string :email
      t.string :mobile_one
      t.string :mobile_two
      t.integer :broker_id

      t.timestamps null: false
    end
  end
end
