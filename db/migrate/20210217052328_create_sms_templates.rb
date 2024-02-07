class CreateSmsTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_templates do |t|
      t.string :title
      t.text :body
      t.integer :business_unit_id
      t.integer :send_after_days
      t.boolean :live
      t.boolean :lost
      t.boolean :ad_hoc
      t.boolean :inactive
      t.integer :organisation_id

      t.timestamps null: false
    end
  end
end
