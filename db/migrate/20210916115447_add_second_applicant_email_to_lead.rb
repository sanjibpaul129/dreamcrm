class AddSecondApplicantEmailToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_email, :string
  end
end
