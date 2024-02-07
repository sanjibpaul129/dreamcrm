class CreateBulkRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_recipients do |t|
      t.string :email
      t.string :mobile
      t.string :field_one
      t.string :field_two
      t.string :field_three
      t.string :field_four
      t.string :field_five
      t.boolean :email_sent
      t.boolean :whatsapp_sent
      t.boolean :sms_sent
      t.text :remarks

      t.timestamps null: false
    end
  end
end
