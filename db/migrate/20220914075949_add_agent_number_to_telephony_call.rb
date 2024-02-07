class AddAgentNumberToTelephonyCall < ActiveRecord::Migration[5.2]
  def change
    add_column :telephony_calls, :agent_number, :string
  end
end
