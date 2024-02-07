class PostSalesController < ApplicationController

def booked_flats_to_confirm
	@projects=selections(BusinessUnit, :name)
	@blocks=[['All', -1]]
	Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
		@blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
	end
	if params[:refresh]=='Refresh'
		project_selected=params[:project][:selected]
		block_selected=params[:project][:block_id]
		if block_selected=='-1'
			@flats=Flat.includes(:block).where(:blocks => {business_unit_id: project_selected}, status: true)		
		else
			@flats=Flat.where(block_id: block_selected, status: true)		
		end		
	end
end

def booking_entry
Booking.transaction do	
	params[:flat_ids].each do |flat_id|
		if Lead.find_by(flat_id: flat_id)==nil
			@error='not connected to lead'
		else
			if CostSheetSent.where(lead_id: Lead.find_by(flat_id: flat_id).id)==[]
				@error='no cost sheet sent'
			else
				booking=Booking.new
				booking.lead_id=Lead.find_by(flat_id: flat_id).id
				booking.cost_sheet_id=CostSheetSent.where(lead_id: Lead.find_by(flat_id: flat_id).id).last.id
				booking.personnel_id=current_personnel.id
				booking.date=Date.today
				booking.save
				ledger_entry_header=LedgerEntryHeader.new
				ledger_entry_header.booking_id=booking.id
				ledger_entry_header.date=Date.today
				ledger_entry_header.transaction_type_id=TransactionType.find_by(name: 'demand').id
				ledger_entry_header.amount=Milestone.find_by(payment_plan_id: CostSheet.find(booking.cost_sheet_id).payment_plan_id, order: 1).amount
				ledger_entry_header.save
				ledger_entry_item=LedgerEntryItem.new
				ledger_entry_item.milestone_id=Milestone.find_by(payment_plan_id: CostSheet.find(booking.cost_sheet_id).payment_plan_id, order: 1).id
				ledger_entry_item.save
			end
		end
	end
end	
redirect_to :back
end

def time_linked_demand_to_be_raised
end

def generate_time_linked_demand
end

def milestone_linked_demand_to_be_raised
end

def generate_milestone_linked_demand
end

def money_receipt_entry_form
end

def money_receipt_entry
end

def applicant_ledger
end

end
