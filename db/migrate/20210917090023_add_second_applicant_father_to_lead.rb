class AddSecondApplicantFatherToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :Second_applicant_father, :string
  end
end
