class CreateProjectDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :project_documents do |t|
      t.integer :project_id
      t.integer :document_id
      t.string :link

      t.timestamps
    end
  end
end
