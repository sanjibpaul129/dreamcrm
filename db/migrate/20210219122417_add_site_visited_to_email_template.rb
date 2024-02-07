class AddSiteVisitedToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :site_visited, :boolean
  end
end
