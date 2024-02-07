class AddQualificationOfSecondApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :qualification_of_second_applicant, :string
  end
end
