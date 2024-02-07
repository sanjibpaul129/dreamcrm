class AddLostToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :lost, :boolean
  end
end
