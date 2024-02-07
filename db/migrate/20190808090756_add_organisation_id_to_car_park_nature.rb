class AddOrganisationIdToCarParkNature < ActiveRecord::Migration[5.2]
  def change
    add_column :car_park_natures, :organisation_id, :integer
  end
end
