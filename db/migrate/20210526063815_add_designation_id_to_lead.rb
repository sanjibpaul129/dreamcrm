class AddDesignationIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :designation_id, :integer
  end
end
