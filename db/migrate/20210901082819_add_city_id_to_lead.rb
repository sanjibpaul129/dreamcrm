class AddCityIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :city_id, :integer
  end
end
