class AddAnniversaryWishToEmailTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :anniversary_wish, :boolean
  end
end
