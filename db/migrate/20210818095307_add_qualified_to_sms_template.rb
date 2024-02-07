class AddQualifiedToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :qualified, :boolean
  end
end
