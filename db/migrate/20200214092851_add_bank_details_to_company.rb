class AddBankDetailsToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :bank_details, :text
  end
end
