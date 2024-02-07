class LedgerEntryItem < ApplicationRecord
	belongs_to :ledger_entry_header
	belongs_to :milestone

def milestone_amount(milestone_id)
	milestone=Milestone.find(milestone_id)
	previous_milestone=Milestone.find_by(payment_plan_id: milestone.payment_plan_id, order: milestone.order-1)
	total_flat_amount=self.unit_gross+self.plc_gross+self.flc_gross+self.parking[1]-(self.discount[1].to_f)
	if previous_milestone==nil
		deduction=0
	elsif previous_milestone.flat_value_percentage==nil
		deduction=previous_milestone.amount.to_i
	else
		deduction=0
	end
	  
	if milestone.flat_value_percentage==nil
	    unit=milestone.amount.to_i
	else
	    unit=((((total_flat_amount)*milestone.flat_value_percentage)/100)-deduction).round
    end  

	if milestone.extra_development_charge_percentage==nil
	  	extra=0
	else
	 	extra=((self.edc*milestone.extra_development_charge_percentage)/100).round
	end
	  
	gross=(unit+extra).round
	return gross
end


def unit_basic
	milestone=self.milestone
	previous_milestone=Milestone.find_by(payment_plan_id: milestone.payment_plan_id, order: milestone.order-1)
	cost_sheet=self.ledger_entry_header.booking.cost_sheet
	flat_basic=cost_sheet.unit_cost+cost_sheet.ota_basic+cost_sheet.plc_basic+cost_sheet.flc_basic+cost_sheet.servant_quarter_basic-(cost_sheet.discount[0].to_f)
	if previous_milestone==nil
		deduction=0
	elsif previous_milestone.flat_value_percentage==nil
		deduction=previous_milestone.amount.to_i
	else
		deduction=0
	end	  
	if milestone.flat_value_percentage==nil
    	unit=milestone.amount.to_i
    else
    	unit=((((flat_basic)*milestone.flat_value_percentage)/100)-deduction).round
    end  
	return unit
end





def amount
	milestone=self.milestone
	previous_milestone=Milestone.find_by(payment_plan_id: milestone.payment_plan_id, order: milestone.order-1)
	cost_sheet=self.ledger_entry_header.booking.cost_sheet
	total_flat_amount=cost_sheet.unit_gross+cost_sheet.plc_gross+cost_sheet.flc_gross+cost_sheet.parking[1]-(cost_sheet.discount[1].to_f)
	
	if previous_milestone==nil
		deduction=0
	elsif previous_milestone.flat_value_percentage==nil
		deduction=previous_milestone.amount.to_i
	else
		deduction=0
	end
	  
	if milestone.flat_value_percentage==nil
    	unit=milestone.amount.to_i
    else
    	unit=((((total_flat_amount)*milestone.flat_value_percentage)/100)-deduction).round
    end  

    if milestone.extra_development_charge_percentage==nil
		extra=0
	else
		extra=((cost_sheet.edc*(milestone.extra_development_charge_percentage))/100).round
    end
	  
	gross=(unit+extra).round
	return gross
end






end
