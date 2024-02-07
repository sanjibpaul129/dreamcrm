class AddFirstApplicantMotherToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :first_applicant_mother, :string
  end
end
