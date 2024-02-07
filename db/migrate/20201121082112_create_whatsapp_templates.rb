class CreateWhatsappTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :whatsapp_templates do |t|
      t.string :title
      t.text :body
      t.integer :business_unit_id
      t.integer :send_after_days

      t.timestamps null: false
    end
  end
end
