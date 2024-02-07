class AddBookedToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :Booked, :boolean
  end
end
