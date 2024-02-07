class RemovePreferredLocationIdFromLead < ActiveRecord::Migration[5.2]
  def change
    remove_column :leads, :preferred_location_id, :integer
  end
end
