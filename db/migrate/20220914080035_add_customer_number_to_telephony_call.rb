class AddCustomerNumberToTelephonyCall < ActiveRecord::Migration[5.2]
  def change
    add_column :telephony_calls, :customer_number, :string
  end
end
