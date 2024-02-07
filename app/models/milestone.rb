class Milestone < ApplicationRecord
	belongs_to :payment_milestone
	belongs_to :payment_plan

	def block_level_future_milestone_amount(block_id)
		bookings = Booking.includes(:cost_sheet => [:payment_plan, :flat]).where(:payment_plans => {id: self.payment_plan_id.to_i}, :flats => {block_id: block_id.to_i}).where(ignore: nil)
		booking_ids=bookings.pluck(:id)
		ledger_entry_items = LedgerEntryItem.includes(:ledger_entry_header).where(:ledger_entry_headers => {booking_id: booking_ids}).where(milestone_id: self.id)

		total_amount=0
		bookings.each do |booking|
			entry_found = false
			ledger_entry_items.each do |ledger_entry_item|
				if ledger_entry_item.ledger_entry_header.booking_id == booking.id
					entry_found = true
				end
			end
			if entry_found == false
				total_amount+=booking.cost_sheet.milestone_amount(self.id)
			end
		end

		return total_amount
	end

	def floor_level_future_milestone_amount(block_id, floor)
		bookings = Booking.includes(:cost_sheet => [:payment_plan, :flat]).where(:payment_plans => {id: self.payment_plan_id.to_i}, :flats => {block_id: block_id.to_i, floor: floor.to_i}).where(ignore: nil)
		booking_ids=bookings.pluck(:id)
		ledger_entry_items = LedgerEntryItem.includes(:ledger_entry_header).where(:ledger_entry_headers => {booking_id: booking_ids}).where(milestone_id: self.id)

		total_amount=0
		bookings.each do |booking|
			entry_found = false
			ledger_entry_items.each do |ledger_entry_item|
				if ledger_entry_item.ledger_entry_header.booking_id == booking.id
					entry_found = true
				end
			end
			if entry_found == false
				total_amount+=booking.cost_sheet.milestone_amount(self.id)
			end
		end

		return total_amount
	end
end
