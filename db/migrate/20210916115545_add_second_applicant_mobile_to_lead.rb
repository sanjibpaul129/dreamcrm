class AddSecondApplicantMobileToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_mobile, :string
  end
end
