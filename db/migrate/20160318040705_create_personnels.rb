class CreatePersonnels < ActiveRecord::Migration[5.2]
  def change
    create_table :personnels do |t|
      t.string :email
      t.string :name
      t.string :passwordhash
      t.string :passwordsalt
      t.string :auth_token
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.string :mobile

      t.timestamps
    end
  end
end
