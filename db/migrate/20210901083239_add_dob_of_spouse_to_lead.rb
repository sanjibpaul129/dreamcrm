class AddDobOfSpouseToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :dob_of_spouse, :datetime
  end
end
