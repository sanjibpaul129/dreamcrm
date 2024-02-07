class AddWifeOfSecondApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :wife_of_second_applicant, :boolean
  end
end
