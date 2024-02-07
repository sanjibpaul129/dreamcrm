class AddSvFormSignatureToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :sv_form_signature, :text
  end
end
