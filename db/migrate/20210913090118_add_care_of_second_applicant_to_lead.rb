class AddCareOfSecondApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :care_of_second_applicant, :boolean
  end
end
