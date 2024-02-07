class Booking < ApplicationRecord
  belongs_to :cost_sheet
  has_many :demand_money_receipts
  has_many :ledger_entry_headers
  has_many :demand_reminder_logs
  def demand_outstanding
  	demand_bill_amount=0
  	demand_money_receipt_amount=0
    adhoc_amount=0
    credit_note_amount=0
  	@ledger_entry_headers=LedgerEntryHeader.where(booking_id: self.id)
  	@demand_money_receipts=DemandMoneyReceipt.where(booking_id: self.id)
    @adhoc_charge_entries=AdhocChargeEntry.where(booking_id: self.id)
    @credit_note_entries=CreditNoteEntry.where(booking_id: self.id)
  	@ledger_entry_headers.each do |ledger_entry_header|
  		demand_bill_amount+=ledger_entry_header.amount
    end
    @adhoc_charge_entries.each do |adhoc_charge_entry|
      adhoc_amount+=adhoc_charge_entry.amount
    end
  	@demand_money_receipts.each do |demand_money_receipt|
  		demand_money_receipt_amount+=demand_money_receipt.amount
  	end
    @credit_note_entries.each do |credit_note_entry|
      credit_note_amount+=credit_note_entry.amount
    end
    	return (demand_bill_amount+adhoc_amount)-(demand_money_receipt_amount+credit_note_amount)
  end

  def total_demanded_till_date
    total_demand_bill_amount=0
    total_adhoc_amount=0
    @ledger_entry_headers=LedgerEntryHeader.where(booking_id: self.id)
    @adhoc_charge_entries=AdhocChargeEntry.where(booking_id: self.id)
    @ledger_entry_headers.each do |ledger_entry_header|
      total_demand_bill_amount+=ledger_entry_header.amount
    end
    @adhoc_charge_entries.each do |adhoc_charge_entry|
      total_adhoc_amount+=adhoc_charge_entry.amount
    end

    return (total_demand_bill_amount+total_adhoc_amount)
  end

  def total_payment_till_date
    total_demand_money_receipt_amount=0
    total_credit_note_amount=0
    @demand_money_receipts=DemandMoneyReceipt.where(booking_id: self.id)
    @credit_note_entries=CreditNoteEntry.where(booking_id: self.id)
    @demand_money_receipts.each do |demand_money_receipt|
      total_demand_money_receipt_amount+=demand_money_receipt.amount
    end
    @credit_note_entries.each do |credit_note_entry|
      total_credit_note_amount+=credit_note_entry.amount
    end

    return (total_demand_money_receipt_amount+total_credit_note_amount)
  end

  def total_demanded_percentage
    total_demanded_percentage=0
    LedgerEntryItem.includes(:ledger_entry_header).where(:ledger_entry_headers => {booking_id: self.id}).each do |ledger_entry_item|
      if ledger_entry_item.milestone.flat_value_percentage == nil || ledger_entry_item.milestone.flat_value_percentage == ''
      else
        total_demanded_percentage += ledger_entry_item.milestone.flat_value_percentage
      end
    end  

    return total_demanded_percentage
  end

  def demand_generated(milestone)
    generated = false
    ledger_entry_headers = LedgerEntryHeader.where(booking_id: self.id)
    ledger_entry_headers.each do |ledger_entry_header|
      if ledger_entry_header.ledger_entry_items.where(milestone_id: milestone.id) == []
        generated = false
      else
        generated = true
        break
      end
    end
    return generated
  end
end
