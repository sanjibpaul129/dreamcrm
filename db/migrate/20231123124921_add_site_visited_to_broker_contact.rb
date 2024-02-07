class AddSiteVisitedToBrokerContact < ActiveRecord::Migration[5.2]
  def change
    add_column :broker_contacts, :site_visited, :boolean
  end
end
