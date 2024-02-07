class RemoveSecondApplicantCompanyIdFromLead < ActiveRecord::Migration[5.2]
  def change
    remove_column :leads, :second_applicant_company_id, :integer
  end
end
