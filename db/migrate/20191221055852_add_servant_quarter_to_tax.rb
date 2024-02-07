class AddServantQuarterToTax < ActiveRecord::Migration[5.2]
  def change
    add_column :taxes, :servant_quarter, :decimal
  end
end
