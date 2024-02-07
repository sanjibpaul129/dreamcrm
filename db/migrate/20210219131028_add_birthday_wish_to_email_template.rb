class AddBirthdayWishToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :birthday_wish, :boolean
  end
end
