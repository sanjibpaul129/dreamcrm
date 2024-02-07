class AddGenderToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :gender, :string
  end
end
