class Addorgidtopersonnels < ActiveRecord::Migration[5.2]
  def change
  add_column :personnels, :organisation_id, :integer
  end
end
