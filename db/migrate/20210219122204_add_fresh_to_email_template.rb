class AddFreshToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :fresh, :boolean
  end
end
