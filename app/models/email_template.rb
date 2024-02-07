class EmailTemplate < ApplicationRecord
	belongs_to :business_unit
	has_many :email_images
	has_many :email_attachments
end
