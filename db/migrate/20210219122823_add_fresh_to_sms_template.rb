class AddFreshToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :fresh, :boolean
  end
end
