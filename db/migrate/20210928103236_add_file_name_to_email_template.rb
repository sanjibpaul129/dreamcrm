class AddFileNameToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :file_name, :string
  end
end
