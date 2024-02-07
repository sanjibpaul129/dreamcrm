class CreateFollowUps < ActiveRecord::Migration[5.2]
  def change
    create_table :follow_ups do |t|
      t.integer :lead_id
      t.string :remarks
      t.datetime :communication_time
      t.datetime :follow_up_time
      t.integer :personnel_id
      t.boolean :status
      t.integer :business_unit_id
      t.boolean :escalated
      t.boolean :hot

      t.timestamps
    end
  end
end
