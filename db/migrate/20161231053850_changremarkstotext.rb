class Changremarkstotext < ActiveRecord::Migration[5.2]
  def change
  	change_column :follow_ups, :remarks, :text
  end
end
