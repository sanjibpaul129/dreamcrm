class ChangeAddressFromStringToText < ActiveRecord::Migration[5.2]
  def change
  	change_column :leads, :address, :text
  end
end
