class AddChildSchoolToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :child_school, :text
  end
end
