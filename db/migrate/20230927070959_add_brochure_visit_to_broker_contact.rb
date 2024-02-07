class AddBrochureVisitToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :brochure_visit, :integer
  end
end
