class AddVisitOrganisedOnToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :visit_organised_on, :datetime
  end
end
