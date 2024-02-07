class AddVirtuallyVisitedOnToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :virtually_visited_on, :datetime
  end
end
