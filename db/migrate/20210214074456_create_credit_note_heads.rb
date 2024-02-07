class CreateCreditNoteHeads < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_note_heads do |t|
      t.string :description
      t.integer :organisation_id

      t.timestamps null: false
    end
  end
end
