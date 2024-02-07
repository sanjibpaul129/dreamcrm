class AddRelativeOfSecondApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :relative_of_second_applicant, :string
  end
end
