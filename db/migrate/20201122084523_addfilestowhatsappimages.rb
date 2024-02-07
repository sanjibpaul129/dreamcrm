class Addfilestowhatsappimages < ActiveRecord::Migration[5.2]
def self.up
    change_table :whatsapp_images do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :whatsapp_images, :image
  end
end
