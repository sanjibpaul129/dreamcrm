class Addfilestoemailattachments < ActiveRecord::Migration[5.2]
def self.up
    change_table :email_attachments do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :email_attachments, :data
  end
end
