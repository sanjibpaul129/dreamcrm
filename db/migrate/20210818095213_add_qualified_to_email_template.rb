class AddQualifiedToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :qualified, :boolean
  end
end
