class CreateLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads do |t|
      t.integer :business_unit_id
      t.integer :personnels_id
      t.integer :budget
      t.boolean :status
      t.string :personnel_remarks
      t.string :name
      t.string :email
      t.integer :lost_reason_id
      t.string :address
      t.integer :occupation_id
      t.string :requirement
      t.integer :area
      t.string :mobile
      t.integer :preferred_location_id
      t.integer :marketing_instance_id
      t.integer :source_category_id
      t.string :customer_remarks
      t.integer :newspaper_id
      t.integer :channel_id
      t.integer :station_id
      t.integer :magazine_id
      t.integer :community_id
      t.integer :nationality_id
      t.string :pan
      t.datetime :dob
      t.string :company
      t.string :designation
      t.string :first_applicant
      t.string :second_applicant

      t.timestamps
    end
  end
end
