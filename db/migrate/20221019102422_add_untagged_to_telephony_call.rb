class AddUntaggedToTelephonyCall < ActiveRecord::Migration[5.2]
  def change
    add_column :telephony_calls, :untagged, :boolean
  end
end
