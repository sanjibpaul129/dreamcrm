class RemoveLeadIdFromDailyCalling < ActiveRecord::Migration[5.2]
  def change
    remove_column :daily_callings, :lead_id, :integer
  end
end
