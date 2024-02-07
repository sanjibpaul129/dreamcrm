class Block < ApplicationRecord
belongs_to :business_unit
has_many :flats
has_many :plc_charges
has_many :payment_plans
has_many :extra_development_charges

	def block_level_pending_milestones(payment_plan_id)
		milestones=Milestone.includes(:payment_milestone).where(:payment_milestones => {block_level: true}).where(payment_plan_id: payment_plan_id.to_i)
		milestone_ids=milestones.pluck(:id)	

		bookings = Booking.includes(:cost_sheet => [:payment_plan]).where(:payment_plans => {id: payment_plan_id.to_i, block_id: self.id}).where(ignore: nil)
		booking_ids=bookings.pluck(:id).uniq
		ledger_entry_items = LedgerEntryItem.includes(:ledger_entry_header).where(:ledger_entry_headers => {booking_id: booking_ids}).where(milestone_id: milestone_ids)
		all_pending_milestones=[]
		if ledger_entry_items == []
			milestones.each do |milestone|
				if milestone.block_level_future_milestone_amount(self.id) == 0
				else
					all_pending_milestones+=[milestone]
				end
			end
			return all_pending_milestones
		else
			pending_milestone_ids = milestone_ids.reject{|x| ledger_entry_items.pluck(:milestone_id).uniq.include? x}
			pending_milestones = Milestone.where(id: pending_milestone_ids)
			pending_milestones.each do |milestone|
				if milestone.block_level_future_milestone_amount(self.id) == 0
				else
					all_pending_milestones+=[milestone]
				end
			end
			return all_pending_milestones
		end
	end

	def floor_wise_pending_milestones(data)
		payment_plan_id = data
		# floor = data[1]
		milestones=Milestone.includes(:payment_milestone).where(:payment_milestones => {floor_level: true}).where(payment_plan_id: payment_plan_id.to_i)
		# milestone_ids=milestones.pluck(:id)	
		# bookings = Booking.includes(:cost_sheet => [:payment_plan, :flat]).where(:payment_plans => {id: payment_plan_id.to_i, block_id: self.id}, :flats => {floor: floor.to_i}).where(ignore: nil)
		# booking_ids=bookings.pluck(:id).uniq
		# ledger_entry_items = LedgerEntryItem.includes(:ledger_entry_header).where(:ledger_entry_headers => {booking_id: booking_ids}).where(milestone_id: milestone_ids)
		
		# if ledger_entry_items == []
		# 	return milestones
		# else
		# 	pending_milestone_ids = milestone_ids.reject{|x| ledger_entry_items.pluck(:milestone_id).uniq.include? x}
		# 	pending_milestones = Milestone.where(id: pending_milestone_ids)
		# 	return pending_milestones
		# end
		milestones = milestones.uniq
		all_pending_milestones=[]
		milestones.each do |milestone|
			(self.floors).times do |floor|
				if milestone.floor_level_future_milestone_amount(self.id, (floor+1)) == 0
				else
					all_pending_milestones+=[milestone]
				end
			end
		end
		return all_pending_milestones.uniq
	end
end
