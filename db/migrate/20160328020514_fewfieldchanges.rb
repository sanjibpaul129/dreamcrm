class Fewfieldchanges < ActiveRecord::Migration[5.2]
  def change
  add_column :leads, :nature, :integer
  add_column :leads, :nature_id, :integer
  remove_column :emails, :lead_id, :integer
  add_column :leads, :personnel_id, :integer
  remove_column :leads, :personnels_id, :integer
  add_column :calls, :personnel_id, :integer
  remove_column :calls, :personnels_id, :integer
  end
end
