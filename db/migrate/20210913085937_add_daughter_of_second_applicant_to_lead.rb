class AddDaughterOfSecondApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :daughter_of_second_applicant, :boolean
  end
end
