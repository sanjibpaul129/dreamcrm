class BrokerProjectStatus < ApplicationRecord
	belongs_to :broker
	belongs_to :business_unit
end
