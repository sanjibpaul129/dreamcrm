class AddBookedToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :Booked, :boolean
  end
end
