class AddSecondApplicantOccupationIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_occupation_id, :integer
  end
end
