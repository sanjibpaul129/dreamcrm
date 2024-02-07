class AddIncomeToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :income, :string
  end
end
