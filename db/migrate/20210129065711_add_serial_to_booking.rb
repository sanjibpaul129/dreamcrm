class AddSerialToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :serial, :integer
  end
end
