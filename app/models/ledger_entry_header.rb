class LedgerEntryHeader < ApplicationRecord
	has_many :ledger_entry_items
	belongs_to :booking
def amount
	total=0
	self.ledger_entry_items.each do |ledger_entry_item|
	total+=(self.booking.cost_sheet.milestone_amount(ledger_entry_item.milestone_id))
	end
	return total
end

def full_description
	full_description=''
	self.ledger_entry_items.each do |ledger_entry_item|
	full_description+=ledger_entry_item.milestone.payment_milestone.description+','  
	  end
	full_description[full_description.length-1]=''

	return full_description
end

def demand_raised_previously
	ledger_entry_headers = LedgerEntryHeader.where(booking_id: self.booking_id).where('created_at < ?', self.created_at)
	total_amount=0
	ledger_entry_headers.each do |ledger_entry_header|
		ledger_entry_header.ledger_entry_items.each do |ledger_entry_item|
			total_amount+=ledger_entry_header.booking.cost_sheet.milestone_amount(ledger_entry_item.milestone_id)
		end
	end
	return total_amount
end

def payement_received_till_date
	demand_money_receipts = DemandMoneyReceipt.where(booking_id: self.booking_id).where('created_at < ?', self.created_at)
	total_paid_amount=0
	demand_money_receipts.each do |demand_money_receipt|
		total_paid_amount+=demand_money_receipt.amount
	end
	
	return total_paid_amount
end

end
