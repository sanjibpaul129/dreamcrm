class AddNoReminderToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :no_reminder, :boolean
  end
end
