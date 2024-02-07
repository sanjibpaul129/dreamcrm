class AddIftttTokenToPersonnel < ActiveRecord::Migration[5.2]
  def change
    add_column :personnels, :ifttt_token, :string
  end
end
