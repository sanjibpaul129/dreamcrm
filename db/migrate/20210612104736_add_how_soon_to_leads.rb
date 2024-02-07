class AddHowSoonToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :how_soon, :string
  end
end
