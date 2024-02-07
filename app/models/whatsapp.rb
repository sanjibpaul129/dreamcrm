class Whatsapp < ApplicationRecord
	belongs_to :lead
	# if by_lead is false then the lead has shown interest again from another source
end
