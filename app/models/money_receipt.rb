class MoneyReceipt < ApplicationRecord
	belongs_to :lead
	belongs_to :flat
	belongs_to :maintainence_bill, foreign_key: :lead_id

def self.manual_money_receipt_unsent
	(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: nil}))+(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: ''}))
end

def self.bulk_money_receipt_unsent
	(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: nil}))+(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: ""}))
end

end
