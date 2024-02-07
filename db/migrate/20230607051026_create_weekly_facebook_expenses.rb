class CreateWeeklyFacebookExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :weekly_facebook_expenses do |t|
      t.string :ad_id
      t.decimal :amount
      t.integer :week

      t.timestamps null: false
    end
  end
end
