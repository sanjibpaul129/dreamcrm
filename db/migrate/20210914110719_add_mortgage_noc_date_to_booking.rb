class AddMortgageNocDateToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :mortgage_noc_date, :datetime
  end
end
