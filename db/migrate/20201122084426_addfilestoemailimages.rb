class Addfilestoemailimages < ActiveRecord::Migration[5.2]
  def self.up
    change_table :email_images do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :email_images, :image
  end
end
