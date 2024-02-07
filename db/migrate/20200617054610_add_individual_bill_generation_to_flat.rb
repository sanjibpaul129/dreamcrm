class AddIndividualBillGenerationToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :individual_bill_generation, :boolean
  end
end
