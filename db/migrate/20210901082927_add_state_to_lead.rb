class AddStateToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :state, :string
  end
end
