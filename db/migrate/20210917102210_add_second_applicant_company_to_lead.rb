class AddSecondApplicantCompanyToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_company, :string
  end
end
