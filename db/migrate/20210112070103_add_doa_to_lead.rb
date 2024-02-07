class AddDoaToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :doa, :datetime
  end
end
