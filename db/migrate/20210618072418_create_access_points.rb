class CreateAccessPoints < ActiveRecord::Migration[5.2]
  def change
    create_table :access_points do |t|
      t.string :action
      t.string :controller
      t.string :menu
      t.string :submenu
      t.string :order
      t.string :name
      t.string :method

      t.timestamps null: false
    end
  end
end
