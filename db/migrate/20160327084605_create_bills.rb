class CreateBills < ActiveRecord::Migration[5.2]
  def change
    create_table :bills do |t|
      t.string :number
      t.datetime :date
      t.string :remarks
      t.boolean :status

      t.timestamps
    end
  end
end
