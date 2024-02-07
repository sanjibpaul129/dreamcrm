class AddWalkthroughToBusinessUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :walkthrough, :string
  end
end
