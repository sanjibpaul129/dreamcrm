class AddAdHocToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :ad_hoc, :boolean
  end
end
