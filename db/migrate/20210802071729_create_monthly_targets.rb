class CreateMonthlyTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :monthly_targets do |t|
      t.integer :business_unit_id
      t.integer :month
      t.integer :year
      t.integer :leads
      t.integer :bookings
      t.integer :collection
      t.integer :activities
      t.integer :leads_achieved
      t.integer :bookings_achieved
      t.integer :collection_achieved
      t.integer :activities_achieved

      t.timestamps null: false
    end
  end
end
