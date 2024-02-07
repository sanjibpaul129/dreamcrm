class AddCancelledToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :cancelled, :boolean
  end
end
