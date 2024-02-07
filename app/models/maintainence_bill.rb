class MaintainenceBill < ApplicationRecord
	belongs_to :business_unit
	belongs_to :company
	belongs_to :lead
	belongs_to :flat
	has_many :money_receipts

def basic_amount
	amount=self.amount
	basic_amount=(amount/1.18).round
	return basic_amount
end

def partial_month_amount(from_date, to_date, monthly_amount)
    days_in_range=(to_date-from_date+1).to_i
    total_days_in_month=(to_date.end_of_month-from_date.beginning_of_month+1).to_i
    return ((monthly_amount.to_f*days_in_range.to_f)/total_days_in_month.to_f)
end

def bill_amount
	from_date=self.from.to_date
	to_date=self.to.to_date
	bill_amount=0.to_f
	until from_date > to_date do 
		if from_date != from_date.beginning_of_month
			if to_date <= from_date.end_of_month
				bill_amount+=partial_month_amount(from_date, to_date, (self.rate.to_f*self.flat.SBA.to_f))
				break
			else
				bill_amount+=partial_month_amount(from_date, from_date.end_of_month, (self.rate.to_f*self.flat.SBA.to_f))
				from_date=from_date.end_of_month+1.day
			end
		else
			if to_date <= from_date.end_of_month
				bill_amount+=partial_month_amount(from_date, to_date, (self.rate.to_f*self.flat.SBA.to_f))
				break
			else
				bill_amount+=(self.rate.to_f*self.flat.SBA.to_f)
				from_date=from_date.end_of_month+1.day
			end
		end
	end
	return bill_amount
end

def self.manual_unsent
	(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: nil}))+(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: ''}))
end

def self.bulk_unsent
	(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: nil}))+(includes(:lead).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: ""}))
end

end
