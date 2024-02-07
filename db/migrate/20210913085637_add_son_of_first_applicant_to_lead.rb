class AddSonOfFirstApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :son_of_first_applicant, :boolean
  end
end
