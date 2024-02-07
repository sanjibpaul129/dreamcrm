class AddQualityConsciousRatingToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :quality_conscious_rating, :integer
  end
end
