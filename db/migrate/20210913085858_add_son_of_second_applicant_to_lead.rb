class AddSonOfSecondApplicantToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :son_of_second_applicant, :boolean
  end
end
