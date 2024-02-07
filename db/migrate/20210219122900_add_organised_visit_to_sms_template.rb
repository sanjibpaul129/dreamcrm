class AddOrganisedVisitToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :organised_visit, :boolean
  end
end
