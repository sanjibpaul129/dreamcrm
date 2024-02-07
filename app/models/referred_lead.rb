class ReferredLead < ApplicationRecord
	belongs_to :wish_to_customer
	belongs_to :lead
end
