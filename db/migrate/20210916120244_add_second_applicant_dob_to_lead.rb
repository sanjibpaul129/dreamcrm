class AddSecondApplicantDobToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_DOB, :datetime
  end
end
