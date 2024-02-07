class AddIntroductoryToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :introductory, :boolean
  end
end
