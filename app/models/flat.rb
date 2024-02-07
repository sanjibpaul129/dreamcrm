class Flat < ApplicationRecord
belongs_to :block
belongs_to :lead
has_many :maintainence_bills
has_many :electrical_bills
has_many :reminder_logs

def full_name
	return self.floor.to_s + self.name
end

def flc_charge_rate
  flc_charge_rate=0
  flc_charge=FlcCharge.find_by_block_id(self.block_id) 
  if flc_charge != nil && self.floor>flc_charge.from_floor
     flc_charge_rate=(self.floor-flc_charge.from_floor)*flc_charge.rate
  end
  return flc_charge_rate    
end

def plc_charge_rate
	plc_charge_rate=0
	plc_details=''
	@floor_specific_plcs=PlcCharge.where(block_id: self.block_id, flat_name: self.name, floor: self.floor)
	@floor_specific_plcs.each do |floor_plc|
		plc_charge_rate+=floor_plc.rate
		plc_details+=floor_plc.plc.name+'-'+floor_plc.rate.to_s+','
	end
    @type_specific_plcs=PlcCharge.where(block_id: self.block_id, flat_name: self.name, floor: nil)
	@type_specific_plcs.each do |type_plc|
		plc_charge_rate+=type_plc.rate
		plc_details+=type_plc.plc.name+'-'+type_plc.rate.to_s+','
	end

	return [plc_details.slice(0,plc_details.length-1), plc_charge_rate]

end

def chargeable_terrace
	chargeable_terrace=0
	if self.OTA=='' || self.OTA==nil
	else
	chargeable_terrace=self.OTA*0.5
	end
	return chargeable_terrace
end

def outstanding
	opening_balance=0

	if self.opening_balance==nil
	else
		opening_balance=self.opening_balance
	end

	maintainance_bill_amount=0
	money_receipt_amount=0
	@maintainance_bills=MaintainenceBill.where(flat_id: self.id).sort_by{|maintainance_bill| maintainance_bill.date}
  	@money_receipts=MoneyReceipt.where(flat_id: self.id).sort_by{|money_receipt| money_receipt.date}
  	@maintainance_bills.each do |maintainance_bill|
  		maintainance_bill_amount+=maintainance_bill.amount
  	end
  	@money_receipts.each do |money_receipt|
  		money_receipt_amount+=money_receipt.amount
  	end
  	credit_notes=MaintenanceCreditNoteEntry.where(lead_id: self.lead_id)
  	credit_note_amount=0
  	credit_notes.each do |credit_note|
  		credit_note_amount+=credit_note.amount*1.18
  	end
  	return opening_balance+maintainance_bill_amount-money_receipt_amount-(credit_note_amount.round(2))
end

def electrical_outstanding
	electrical_bill_amount=0
	electrical_money_receipt_amount=0
	@electrical_bills=ElectricalBill.where(flat_id: self.id).sort_by{|electrical_bill| electrical_bill.date}
  	@electrical_money_receipts=ElectricalMoneyReceipt.where(flat_id: self.id).sort_by{|electrical_money_receipt| electrical_money_receipt.date}
  	@electrical_bills.each do |electrical_bill|
  		electrical_bill_amount+=electrical_bill.amount
  	end
  	@electrical_money_receipts.each do |electrical_money_receipt|
  		electrical_money_receipt_amount+=electrical_money_receipt.amount
  	end
  	return electrical_bill_amount-electrical_money_receipt_amount
end

def on_7d_reminder?
	if self.no_reminder==nil
		return true
	else
		return false
	end
end


def on_3d_reminder?
	if self.no_reminder==false
		return true
	else
		return false
	end
end

def accrued_interest
	maintainance_bills = MaintainenceBill.where(flat_id: self.id)
  	money_receipts = MoneyReceipt.where(flat_id: self.id)
	maintenance_credit_notes = MaintenanceCreditNoteEntry.where(lead_id: self.lead_id)
	both_documents = maintainance_bills+money_receipts+maintenance_credit_notes
	both_documents = both_documents.sort_by{|document| document.date}
	balance = 0
	last_balance_date = nil
	last_bill_date = nil
	last_bill_balance_amount = 0
	previous_balance = 0
	last_bill = nil
	total_interest = 0
  	interest = 0
	if self.opening_balance != nil
	  	last_balance_date = ("22/06/2020").to_datetime
	  	balance += self.opening_balance
	end
	both_documents.each_with_index do |both_document, index|  
		if both_document.class == MaintainenceBill
			previous_balance = balance
			balance += both_document.amount
			if last_balance_date == nil
				delay = 0 
				last_balance_date = both_document.date.to_datetime
				last_bill_date = both_document.date.to_datetime
				last_bill_balance_amount = balance
				last_bill = both_document
	  		else
		  		delay = ((both_document.date.to_datetime-last_balance_date.to_datetime).to_i)
		  		last_balance_date = both_document.date.to_datetime
				last_bill_date = both_document.date.to_datetime
				last_bill_balance_amount = balance
				last_bill = both_document
	  		end
	  		interest=((previous_balance*0.18*delay)/365).round
	  		total_interest+= interest
		elsif both_document.class == MoneyReceipt
			previous_balance = balance
			balance = balance-both_document.amount
			if last_balance_date == nil
				delay = 0 
	  			last_balance_date = both_document.date.to_datetime
		  	else
		  		delay = ((both_document.date.to_datetime-last_balance_date.to_datetime).to_i)
		  	end
		  	if last_bill == nil 
				if balance < previous_balance
					if both_document.date <= last_balance_date+15.days
						interest = 0
					else
						interest = ((previous_balance*0.18*delay)/365).round
					end
				end
				last_balance_date = both_document.date.to_datetime 
			else
				if balance < last_bill.amount
					if both_document.date <= last_bill.date+15.days
						(index+1).times do |counter|
							if both_document[counter].class == MaintainenceBill
								if both_document[counter].date == last_bill_date
									actual_interest_amount = last_bill_balance_amount-(both_document[counter].amount-balance)
									interest = ((actual_interest_amount*0.18*delay)/365).round
								end
							end
						end
					else
						interest = ((previous_balance*0.18*delay)/365).round	
					end
				else
				 	interest = ((previous_balance*0.18*delay)/365).round
				end
				last_balance_date = both_document.date.to_datetime 
			end
			total_interest+= interest
		elsif both_document.class == MaintenanceCreditNoteEntry
			previous_balance = balance
			balance = balance-((both_document.amount*1.18).round(2))
			if last_balance_date == nil
				delay = 0 
		  		last_balance_date = both_document.date.to_datetime
		  	else
		  		delay = ((both_document.date.to_datetime-last_balance_date.to_datetime).to_i)
		  	end
		  	if last_bill == nil 
				if balance < previous_balance
					if both_document.date <= last_balance_date+15.days
						interest = 0
					else
						interest = ((previous_balance*0.18*delay)/365).round
					end
				end
				last_balance_date = both_document.date.to_datetime 
			else
				if balance < last_bill.amount
					if both_document.date <= last_bill.date+15.days
						(index+1).times do |counter|
							if both_document[counter].class == MaintainenceBill
								if both_document[counter].date == last_bill_date
									actual_interest_amount = last_bill_balance_amount-(both_document[counter].amount-balance)
									interest = ((actual_interest_amount*0.18*delay)/365).round
								end
							end
						end
					else
						interest = ((previous_balance*0.18*delay)/365).round	
					end
				else
				 	interest = ((previous_balance*0.18*delay)/365).round
				end
				last_balance_date = both_document.date.to_datetime 
			end
		  	total_interest+= interest
		end
	end
	delay = ((DateTime.now.to_datetime-last_balance_date.to_datetime).to_i)
	interest=((balance*0.18*delay)/365).round
	total_interest+= interest

	return total_interest
end

end
