class AddAreaIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :area_id, :integer
  end
end
