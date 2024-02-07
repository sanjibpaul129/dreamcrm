class AddEdcHiddenToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :edc_hidden, :boolean
  end
end
