class AddRelativeOfFirstApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :relative_of_first_applicant, :string
  end
end
