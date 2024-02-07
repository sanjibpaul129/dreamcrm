class AddFreshLeadScoreToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :fresh_lead_score, :integer
  end
end
