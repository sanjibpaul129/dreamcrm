class AddWhatsappToReminderLog < ActiveRecord::Migration[5.2]
  def change
    add_column :reminder_logs, :whatsapp, :boolean
  end
end
