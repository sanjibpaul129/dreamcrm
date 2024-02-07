class AddLeadIdToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :lead_id, :integer
  end
end
