class CreateIncomingCalls < ActiveRecord::Migration[5.2]
  def change
    create_table :incoming_calls do |t|

      t.timestamps null: false
    end
  end
end
