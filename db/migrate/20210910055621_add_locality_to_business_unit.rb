class AddLocalityToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :locality, :string
  end
end
