class AddAnniversaryWishToSmsTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :sms_templates, :anniversary_wish, :boolean
  end
end
