class AddOpeningBalanceToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :opening_balance, :decimal
  end
end
