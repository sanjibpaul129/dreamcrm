class AddSecondApplicantAadharToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_aadhar, :string
  end
end
