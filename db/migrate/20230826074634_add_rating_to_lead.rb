class AddRatingToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :rating, :integer
  end
end
