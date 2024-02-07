class AddAccountNumberToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :account_number, :string
  end
end
