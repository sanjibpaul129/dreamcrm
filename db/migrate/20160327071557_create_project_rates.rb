class CreateProjectRates < ActiveRecord::Migration[5.2]
  def change
    create_table :project_rates do |t|
      t.integer :business_unit_id
      t.integer :base_rate
      t.datetime :date

      t.timestamps
    end
  end
end
