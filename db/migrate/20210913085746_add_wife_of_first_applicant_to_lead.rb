class AddWifeOfFirstApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :wife_of_first_applicant, :boolean
  end
end
