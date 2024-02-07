class Addfieldstoleads < ActiveRecord::Migration[5.2]
  def change
  	add_column :leads, :site_visited_on, :datetime
  	add_column :leads, :booked_on, :datetime
  	add_column :leads, :generated_on, :datetime
  	add_column :leads, :other_number, :string
  	add_column :follow_ups, :follow_up_from, :datetime

  end
end
