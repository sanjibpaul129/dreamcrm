class CreateSourceCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :source_categories do |t|
      t.string :description
      t.integer :organisation_id
      t.integer :predecessor

      t.timestamps
    end
  end
end
