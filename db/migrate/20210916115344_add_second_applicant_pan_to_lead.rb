class AddSecondApplicantPanToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :second_applicant_pan, :string
  end
end
