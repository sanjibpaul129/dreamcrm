class AddAutoAllocateToBusinessUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :business_units, :auto_allocate, :boolean
  end
end
