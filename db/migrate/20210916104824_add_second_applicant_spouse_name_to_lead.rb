class AddSecondApplicantSpouseNameToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_spouse_name, :string
  end
end
