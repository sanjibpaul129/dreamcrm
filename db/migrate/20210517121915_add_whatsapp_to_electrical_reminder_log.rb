class AddWhatsappToElectricalReminderLog < ActiveRecord::Migration[5.2]
  def change
    add_column :electrical_reminder_logs, :whatsapp, :boolean
  end
end
