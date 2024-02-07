class AddInvestmentToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :investment, :boolean
  end
end
