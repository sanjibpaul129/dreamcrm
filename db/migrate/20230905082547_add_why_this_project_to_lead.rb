class AddWhyThisProjectToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :why_this_project, :text
  end
end
