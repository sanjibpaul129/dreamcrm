class AddIndexFirst < ActiveRecord::Migration[5.2]
  def change
    add_index :blocks, :business_unit_id
    add_index :business_units, :company_id
    add_index :business_units, :organisation_id
    add_index :calls, :marketing_number_id
    add_index :calls, :personnel_id
    add_index :companies, :organisation_id
    add_index :emails, :organisation_id
    add_index :flats, :block_id
    add_index :follow_ups, :business_unit_id
    add_index :follow_ups, :lead_id
    add_index :follow_ups, :personnel_id
    add_index :leads, :business_unit_id
    add_index :leads, :lost_reason_id
    add_index :leads, :personnel_id
    add_index :leads, :source_category_id
    add_index :personnels, :business_unit_id
    add_index :personnels, :organisation_id
  end
end
