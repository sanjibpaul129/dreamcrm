class AddJainGroupRatingToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :jain_group_rating, :integer
  end
end
