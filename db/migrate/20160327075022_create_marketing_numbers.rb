class CreateMarketingNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :marketing_numbers do |t|
      t.string :number
      t.integer :organisation_id

      t.timestamps
    end
  end
end
