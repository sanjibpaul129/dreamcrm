class AddContractSignatureToBroker < ActiveRecord::Migration[5.2]
  def change
    add_column :brokers, :contract_signature, :text
  end
end
