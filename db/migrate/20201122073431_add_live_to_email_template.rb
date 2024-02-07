class AddLiveToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :live, :boolean
  end
end
