class Projecttobu < ActiveRecord::Migration[5.2]
  def change
  	add_column :personnels, :business_unit_id, :integer
  	remove_column :personnels, :project_id, :integer
  	add_column :project_documents, :business_unit_id, :integer
  	remove_column :project_documents, :project_id, :integer
  end
end
