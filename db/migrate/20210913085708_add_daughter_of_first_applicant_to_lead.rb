class AddDaughterOfFirstApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :daughter_of_first_applicant, :boolean
  end
end
