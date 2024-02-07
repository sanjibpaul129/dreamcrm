class AddQualifiedOnToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :qualified_on, :datetime
  end
end
