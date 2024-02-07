class CreateSmsFollowups < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_followups do |t|

      t.timestamps
    end
  end
end
