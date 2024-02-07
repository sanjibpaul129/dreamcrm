class CreateBotCommunications < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_communications do |t|
      t.string :customer_number
      t.string :customer_message
      t.string :bot_message

      t.timestamps null: false
    end
  end
end
