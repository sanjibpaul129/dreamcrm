class AddReengagedOnToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :reengaged_on, :datetime
  end
end
