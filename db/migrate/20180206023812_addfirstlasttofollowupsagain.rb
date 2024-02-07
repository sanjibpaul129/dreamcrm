class Addfirstlasttofollowupsagain < ActiveRecord::Migration[5.2]
  def change
  	add_column :follow_ups, :first, :boolean
  	add_column :follow_ups, :last, :boolean
  end
end
