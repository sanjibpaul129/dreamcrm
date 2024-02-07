class CreateAllLeadExports < ActiveRecord::Migration[5.2]
  def change
    create_table :all_lead_exports do |t|
      t.integer :project_id
      t.integer :personnel_id
      t.integer :source_category_id
      t.datetime :from
      t.datetime :to
      t.string :email

      t.timestamps null: false
    end
  end
end
