class WhatsappFollowup < ApplicationRecord
	belongs_to :lead
	belongs_to :broker_contact
end
