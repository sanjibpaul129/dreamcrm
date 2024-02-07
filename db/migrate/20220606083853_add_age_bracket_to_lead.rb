class AddAgeBracketToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :age_bracket, :string
  end
end
