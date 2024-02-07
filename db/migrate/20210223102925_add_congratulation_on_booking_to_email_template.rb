class AddCongratulationOnBookingToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :congratulation_on_booking, :boolean
  end
end
