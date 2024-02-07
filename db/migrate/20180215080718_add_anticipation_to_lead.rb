class AddAnticipationToLead < ActiveRecord::Migration[5.2]
  def change
  	add_column :leads, :anticipation, :boolean
  end
end
