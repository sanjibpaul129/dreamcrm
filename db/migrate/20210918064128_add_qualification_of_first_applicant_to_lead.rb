class AddQualificationOfFirstApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :qualification_of_first_applicant, :string
  end
end
