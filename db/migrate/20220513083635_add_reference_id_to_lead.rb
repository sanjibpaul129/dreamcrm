class AddReferenceIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :reference_id, :string
  end
end
