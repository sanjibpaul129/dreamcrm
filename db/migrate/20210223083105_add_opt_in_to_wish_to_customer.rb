class AddOptInToWishToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :wish_to_customers, :opt_in, :boolean
  end
end
