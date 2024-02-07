class AddBusinessUnitIdToMarketingNumbers < ActiveRecord::Migration[5.2]
  def change
    add_column :marketing_numbers, :business_unit_id, :integer
  end
end
