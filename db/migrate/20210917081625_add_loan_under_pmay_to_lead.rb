class AddLoanUnderPmayToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :loan_under_PMAY, :boolean
  end
end
