class AddIgnoreToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :ignore, :boolean
  end
end
