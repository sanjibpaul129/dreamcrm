class AddFileUrlToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :file_url, :text
  end
end
