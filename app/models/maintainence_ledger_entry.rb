class MaintainenceLedgerEntry < ApplicationRecord
	belongs_to :lead
	belongs_to :money_receipt
end
