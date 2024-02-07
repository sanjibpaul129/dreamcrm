class AddPhoneIdToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :phone_id, :string
  end
end
