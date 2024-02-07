class Addosvtofollowups < ActiveRecord::Migration[5.2]
  def change
  	add_column :follow_ups, :osv, :boolean
  end
end
