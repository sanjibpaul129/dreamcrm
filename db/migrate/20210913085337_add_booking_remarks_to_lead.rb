class AddBookingRemarksToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :booking_remarks, :text
  end
end
