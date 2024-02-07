class AddBankNameToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :bank_name, :string
  end
end
