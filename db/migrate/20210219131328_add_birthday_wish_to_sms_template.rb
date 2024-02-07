class AddBirthdayWishToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :birthday_wish, :boolean
  end
end
