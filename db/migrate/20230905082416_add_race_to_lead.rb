class AddRaceToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :race, :string
  end
end
