class AddFirstApplicantFatherToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :first_applicant_father, :string
  end
end
