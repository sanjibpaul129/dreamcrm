class CreateMonthlyFacebookExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :monthly_facebook_expenses do |t|
      t.string :ad_id
      t.decimal :amount
      t.integer :month

      t.timestamps null: false
    end
  end
end
