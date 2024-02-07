class AddFreshToTelephonyCall < ActiveRecord::Migration[5.2]
  def change
    add_column :telephony_calls, :fresh, :boolean
  end
end
