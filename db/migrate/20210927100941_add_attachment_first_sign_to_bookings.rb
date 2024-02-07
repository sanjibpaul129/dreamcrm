class AddAttachmentFirstSignToBookings < ActiveRecord::Migration[5.2]
  def self.up
    change_table :bookings do |t|
      t.attachment :first_sign
    end
  end

  def self.down
    remove_attachment :bookings, :first_sign
  end
end
