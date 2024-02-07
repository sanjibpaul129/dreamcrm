class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.string :subject
      t.integer :organisation_id
      t.text :body
      t.integer :lead_id
      t.datetime :date
      t.string :from

      t.timestamps
    end
  end
end
