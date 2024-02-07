class ElectricalMoneyReceipt < ApplicationRecord
	belongs_to :flat
	belongs_to :lead
end
