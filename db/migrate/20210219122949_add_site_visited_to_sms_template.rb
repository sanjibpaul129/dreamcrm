class AddSiteVisitedToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :site_visited, :boolean
  end
end
