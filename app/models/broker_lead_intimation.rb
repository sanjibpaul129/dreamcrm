class BrokerLeadIntimation < ApplicationRecord
	belongs_to :business_unit
	belongs_to :broker_contact
	belongs_to :lead
end
