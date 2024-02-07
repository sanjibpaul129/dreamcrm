class AddLeadIdToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :lead_id, :integer
  end
end
