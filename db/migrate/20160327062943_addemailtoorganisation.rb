class Addemailtoorganisation < ActiveRecord::Migration[5.2]
  def change
  	add_column :organisations, :email, :string
  end
end
