class AddVehicleToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :vehicle, :string
  end
end
