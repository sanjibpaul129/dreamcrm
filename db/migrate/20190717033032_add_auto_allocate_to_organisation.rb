class AddAutoAllocateToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :auto_allocate, :boolean
  end
end
