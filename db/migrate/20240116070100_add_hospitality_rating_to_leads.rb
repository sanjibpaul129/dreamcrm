class AddHospitalityRatingToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :hospitality_rating, :integer
  end
end
