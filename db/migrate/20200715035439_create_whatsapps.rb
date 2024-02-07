class CreateWhatsapps < ActiveRecord::Migration[5.2]
  def change
    create_table :whatsapps do |t|
      t.integer :lead_id
      t.text :message
      t.boolean :by_lead

      t.timestamps null: false
    end
  end
end
