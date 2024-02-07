class AddGstToPosessionCharge < ActiveRecord::Migration[5.2]
  def change
    add_column :posession_charges, :gst, :decimal
  end
end
