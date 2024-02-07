class AddDiscountAmountToCostSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_sheets, :discount_amount, :decimal
  end
end
