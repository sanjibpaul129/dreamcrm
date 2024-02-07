class AddSignatureToLead < ActiveRecord::Migration[5.2]
  def self.up
    change_table :leads do |t|
      t.attachment :first_sign
      t.attachment :second_sign
    end
  end

  def self.down
    remove_attachment :leads, :first_sign
    remove_attachment :leads, :second_sign
  end
end
