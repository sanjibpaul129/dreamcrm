class AddHiraRegistrationNumberToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :hira_registration_number, :string
  end
end
