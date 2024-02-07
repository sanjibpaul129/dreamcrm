class AddHolidayToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :holiday, :boolean
  end
end
