class AddSecondApplicantCompanyIdToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_company_id, :integer
  end
end
