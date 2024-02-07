class AddFundSourceToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :fund_source, :string
  end
end
