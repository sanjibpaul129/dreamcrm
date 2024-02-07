class CreateEmailFollowups < ActiveRecord::Migration[5.2]
  def change
    create_table :email_followups do |t|

      t.timestamps
    end
  end
end
