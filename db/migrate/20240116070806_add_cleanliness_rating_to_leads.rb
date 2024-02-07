class AddCleanlinessRatingToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :cleanliness_rating, :integer
  end
end
