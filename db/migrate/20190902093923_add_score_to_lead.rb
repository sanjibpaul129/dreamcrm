class AddScoreToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :score, :decimal
  end
end
