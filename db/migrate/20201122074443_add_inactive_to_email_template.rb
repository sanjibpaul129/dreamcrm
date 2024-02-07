class AddInactiveToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :inactive, :boolean
  end
end
