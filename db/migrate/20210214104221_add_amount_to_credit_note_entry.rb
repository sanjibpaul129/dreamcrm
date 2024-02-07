class AddAmountToCreditNoteEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_note_entries, :amount, :decimal
  end
end
