class AddCongratulationOnBookingToWhatsappTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :whatsapp_templates, :congratulation_on_booking, :boolean
  end
end
