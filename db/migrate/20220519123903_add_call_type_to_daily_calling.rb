class AddCallTypeToDailyCalling < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_callings, :call_type, :string
  end
end
