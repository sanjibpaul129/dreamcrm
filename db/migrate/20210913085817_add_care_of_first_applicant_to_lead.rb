class AddCareOfFirstApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :care_of_first_applicant, :boolean
  end
end
