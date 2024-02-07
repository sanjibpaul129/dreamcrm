class AddSecondApplicantDesignationIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_designation_id, :integer
  end
end
