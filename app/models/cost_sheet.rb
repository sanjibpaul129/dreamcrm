class CostSheet < ApplicationRecord
has_many :sent_cost_sheets
has_many :cost_sheet_car_parkings
belongs_to :flat
belongs_to :lead
belongs_to :payment_plan
has_many :bookings
def unit_cost
	if self.flat.OTA == nil || self.flat.OTA == ""
		return (self.rate)*(self.flat.SBA)
	else
		total_area = self.flat.SBA+(self.flat.OTA/2)
		return (self.rate)*(total_area)
	end
end

def unit_gst
tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
if self.bookings[0]==nil
tax=Tax.find(tax_hash.keys.last)
else
booking_date=self.bookings[0].date
	tax_hash.each do |tax_id, from_to_array|
		if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
			tax=Tax.find(tax_id)
		end
	end
end
if tax==nil	
tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
end
return (self.unit_cost*tax.basic/100).round
end

def unit_gross
return self.unit_cost+unit_gst
end

def ota_basic
chargeable_ota=self.flat.OTA/2 
total_ota=(self.rate*chargeable_ota).round 
return total_ota
end

def ota_gst
tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
if self.bookings[0]==nil
tax=Tax.find(tax_hash.keys.last)
else
booking_date=self.bookings[0].date
	tax_hash.each do |tax_id, from_to_array|
		if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
			tax=Tax.find(tax_id)
		end
	end
end
if tax==nil	
tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
end
gstamt_ota=((self.ota_basic*tax.basic)/100).round 
return gstamt_ota
end

def ota_gross
gross_ota=(self.ota_basic+self.ota_gst).round 
return gross_ota
end

def flc_basic
flc_charge_rate=self.flat.flc_charge_rate        
total_escalation=((self.flat.SBA+self.flat.chargeable_terrace)*flc_charge_rate).round  
return total_escalation
end

def flc_tax
tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
if self.bookings[0]==nil
tax=Tax.find(tax_hash.keys.last)
else
booking_date=self.bookings[0].date
	tax_hash.each do |tax_id, from_to_array|
		if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
			tax=Tax.find(tax_id)
		end
	end
end
if tax==nil	
tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
end
gstamt_escalation=((self.flc_basic*tax.plc)/100).round 
return gstamt_escalation
end

def flc_gross
flc_charge_rate=self.flat.flc_charge_rate        
total_escalation=((self.flat.SBA+self.flat.chargeable_terrace)*flc_charge_rate).round  
tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
if self.bookings[0]==nil
tax=Tax.find(tax_hash.keys.last)
else
booking_date=self.bookings[0].date
	tax_hash.each do |tax_id, from_to_array|
		if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
			tax=Tax.find(tax_id)
		end
	end
end
if tax==nil	
tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
end
gstamt_escalation=((total_escalation*tax.plc)/100).round 
gross_escalation=(total_escalation+gstamt_escalation).round 
return gross_escalation
end

def plc_basic
total_plc=0	
  if self.flat.plc_charge_rate[1]==0 
  else
     plc_charge_rate=self.flat.plc_charge_rate[1]  
     total_plc=((self.flat.SBA+self.flat.chargeable_terrace)*plc_charge_rate).round  
  end
return total_plc
end

def plc_tax
  if self.flat.plc_charge_rate[1]==0 
  else
     tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
     if self.bookings[0]==nil
     tax=Tax.find(tax_hash.keys.last)
     else
     booking_date=self.bookings[0].date
     	tax_hash.each do |tax_id, from_to_array|
     		if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
     			tax=Tax.find(tax_id)
     		end
     	end
     end
     if tax==nil	
     tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
     end
     gst_plc_amnt=((self.plc_basic*tax.plc)/100).round 
  end
return gst_plc_amnt
end

def plc_gross
gross_plc=0	
  if self.flat.plc_charge_rate[1]==0 
  else
     plc_charge_rate=self.flat.plc_charge_rate[1]  
     total_plc=((self.flat.SBA+self.flat.chargeable_terrace)*plc_charge_rate).round  
     tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
     if self.bookings[0]==nil
     tax=Tax.find(tax_hash.keys.last)
     else
     booking_date=self.bookings[0].date
     	tax_hash.each do |tax_id, from_to_array|
     		if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
     			tax=Tax.find(tax_id)
     		end
     	end
     end
     if tax==nil	
     tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
     end
     gst_plc_amnt=((total_plc*tax.plc)/100).round 
     gross_plc=(total_plc+gst_plc_amnt).round 
  end
return gross_plc
end

def servant_quarter_basic
	servant_quarters=ServantQuarter.where(business_unit_id: self.lead.business_unit_id)
  	servant_quarter_quantity=self.servant_quarters
  	servant_quarter_amnt=0
	charges=0
	servant_quarters.each do |servant_quarter|
	    charges=(servant_quarter_quantity*servant_quarter.rate).round
	    servant_quarter_amnt+=charges
	end
return servant_quarter_amnt
end

def servant_quarter_gst
	servant_quarters=ServantQuarter.where(business_unit_id: self.lead.business_unit_id)
  	servant_quarter_quantity=self.servant_quarters
  	servant_quarter_amnt=0
	servant_quarter_gst=0
	servant_quarter_amnt_gross=0
	charges=0
	tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
	if self.bookings[0]==nil
	tax=Tax.find(tax_hash.keys.last)
	else
	booking_date=self.bookings[0].date
		tax_hash.each do |tax_id, from_to_array|
			if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
				tax=Tax.find(tax_id)
			end
		end
	end
	if tax==nil	
	tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
	end
	servant_quarters.each do |servant_quarter|
	    charges=(servant_quarter_quantity*servant_quarter.rate).round
	    servant_quarter_amnt+=charges
	    gstamt_charges=((charges*tax.servant_quarter)/100).round 
	    servant_quarter_gst+=gstamt_charges
	    gross=(charges+gstamt_charges).round 
	    servant_quarter_amnt_gross+=gross
	end
return servant_quarter_gst
end

def servant_quarter_gross
	servant_quarters=ServantQuarter.where(business_unit_id: self.lead.business_unit_id)
  	servant_quarter_quantity=self.servant_quarters
  	servant_quarter_amnt=0
	servant_quarter_gst=0
	servant_quarter_amnt_gross=0
	charges=0
	tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
	if self.bookings[0]==nil
	tax=Tax.find(tax_hash.keys.last)
	else
	booking_date=self.bookings[0].date
		tax_hash.each do |tax_id, from_to_array|
			if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
				tax=Tax.find(tax_id)
			end
		end
	end
	if tax==nil	
	tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
	end
	servant_quarters.each do |servant_quarter|
	    charges=(servant_quarter_quantity*servant_quarter.rate).round
	    servant_quarter_amnt+=charges
	    gstamt_charges=((charges*tax.servant_quarter)/100).round 
	    servant_quarter_gst+=gstamt_charges
	    gross=(charges+gstamt_charges).round 
	    servant_quarter_amnt_gross+=gross
	end
return servant_quarter_amnt_gross
end

def parking_gross
	return 0	
end

def edc
	total_extra_development_charges=0
    total_gst_extra_development_charges=0
    total_extra_development_charges_gross=0
	tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
	if self.bookings[0]==nil
	tax=Tax.find(tax_hash.keys.last)
	else
	booking_date=self.bookings[0].date
		tax_hash.each do |tax_id, from_to_array|
			if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
				tax=Tax.find(tax_id)
			end
		end
	end
	if tax==nil	
	tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
	end
	extra_developments=ExtraDevelopmentCharge.where(business_unit_id: self.flat.block.business_unit_id, flat_type: self.flat.BHK) 
	if extra_developments==[]
		extra_developments=ExtraDevelopmentCharge.where(business_unit_id: self.flat.block.business_unit_id) 	
	end
	extra_developments.each do |extra_development_charge| 
        if extra_development_charge.amount !=nil
           extra_development_charges = extra_development_charge.amount
        elsif extra_development_charge.rate !=nil
            extra_development_charges =((self.flat.SBA)*extra_development_charge.rate).round
        elsif extra_development_charge.percentage != nil
            extra_development_charges =(((self.unit_cost+self.plc_basic+self.flc_basic-self.discount[0]+self.parking[0]+self.servant_quarter)*extra_development_charge.percentage)/100).round 
        end
        total_extra_development_charges+=extra_development_charges
        gst_extra_development_charges =((extra_development_charges*tax.edc)/100).round
        total_gst_extra_development_charges+=gst_extra_development_charges
        extra_development_charges_gross =extra_development_charges+gst_extra_development_charges
        total_extra_development_charges_gross+=extra_development_charges_gross
	end
	return total_extra_development_charges_gross
end 

def servant_quarter
	servant_quarters=ServantQuarter.where(business_unit_id: self.lead.business_unit_id)
  	servant_quarter_quantity=self.servant_quarters
  	servant_quarter_amnt=0
	charges=0
	servant_quarters.each do |servant_quarter|
	    charges=(servant_quarter_quantity*servant_quarter.rate).round
	    servant_quarter_amnt+=charges
	end
	return servant_quarter_amnt
end
#servant quarter

def parking
	total_parking=0.0
    total_gst_parking=0.0
    total_parking_gross=0.0
    parking=0.0
    gstamt_parking=0.0
    gross=0.0
	tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
	if self.bookings[0]==nil
	tax=Tax.find(tax_hash.keys.last)
	else
	booking_date=self.bookings[0].date
		tax_hash.each do |tax_id, from_to_array|
			if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
				tax=Tax.find(tax_id)
			end
		end
	end
	if tax==nil	
	tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
	end
  	car_parks=[]
  	CostSheetCarParking.where(cost_sheet_id: self.id).each do|cost_sheet_car_park_nature|
  	car_park=CarPark.find_by(car_park_nature_id: cost_sheet_car_park_nature.car_parking_nature_id, business_unit_id: self.flat.block.business_unit_id)
		if car_park==nil
		else
		car_parks+=[[car_park,cost_sheet_car_park_nature.quantity]]
	  	end
  	end	

	if car_parks==[]
	else
		car_parks.each do |car_park|
		quantity=car_park[1]	
	    parking=(quantity*car_park[0].rate).round
	    total_parking+=parking
	    gstamt_parking=((parking*tax.car_park)/100).round
	    total_gst_parking+=gstamt_parking
	    gross=(parking+gstamt_parking).round 
	    total_parking_gross+=gross
		end
	end
	return [total_parking, total_parking_gross]
end

def discount
	basic_discount=0
	basic_discount_gross=0
	extra_development_total_percentage=0
	extra_development_charges=ExtraDevelopmentCharge.where(business_unit_id: self.lead.business_unit_id)
  	extra_development_charges.each do |extra_development_charge|
		if extra_development_charge.percentage != nil
		   extra_development_total_percentage+=extra_development_charge.percentage
		end
	end
	tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
	if self.bookings[0]==nil
	tax=Tax.find(tax_hash.keys.last)
	else
	booking_date=self.bookings[0].date
		tax_hash.each do |tax_id, from_to_array|
			if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
				tax=Tax.find(tax_id)
			end
		end
	end
	if tax==nil	
	tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
	end
	final_discount=self.discount_amount
	if final_discount != nil
	basic_discount=(final_discount/(1+(extra_development_total_percentage.to_f/100)))/(1+(tax.basic/100))
	basic_discount_gross=basic_discount*(1+(tax.basic/100))
	end
	return [basic_discount.round, basic_discount_gross] 
end

def milestone_amount(milestone_id)
	milestone = Milestone.find(milestone_id)
	previous_milestone = Milestone.find_by(payment_plan_id: milestone.payment_plan_id, order: milestone.order-1)
	total_flat_amount = self.unit_gross+self.plc_gross+self.flc_gross+self.servant_quarter_gross+self.parking[1]-(self.discount[1].to_f)
	if previous_milestone == nil
		deduction = 0
	elsif previous_milestone.flat_value_percentage == nil
		deduction = previous_milestone.amount.to_i
	else
		deduction = 0
	end
  	if milestone.flat_value_percentage == nil
	    unit = milestone.amount.to_i
	else
	    unit = ((((total_flat_amount)*milestone.flat_value_percentage)/100)-deduction).round
	end  
	if milestone.extra_development_charge_percentage == nil
	  	extra = 0
	else
	  extra = ((self.edc*milestone.extra_development_charge_percentage)/100).round
	end
	gross = (unit+extra).round
	return gross
end

def milestone_breakup_total(milestone_id)
	total=0
	total += self.milestone_breakup_total_without_gst(milestone_id)
	total+=self.milestone_gst(milestone_id)
	return total
end

def milestone_breakup_total_without_gst(milestone_id)
	total=0
	total+=self.milestone_unit_basic(milestone_id)
	total+=self.milestone_plc_basic(milestone_id)
	total+=self.milestone_parking_basic(milestone_id)
	total+=self.milestone_edc_basic(milestone_id)
	return total
end


#for each milestone unit, parking and edc, just gross for now
def milestone_unit_basic(milestone_id)
	milestone=Milestone.find(milestone_id)
	previous_milestone=Milestone.find_by(payment_plan_id: milestone.payment_plan_id, order: milestone.order-1)
	total_flat_amount=self.unit_cost+self.servant_quarter_basic-(self.discount[0].to_f)
	
	tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
	if self.bookings[0]==nil
	tax=Tax.find(tax_hash.keys.last)
	else
	booking_date=self.bookings[0].date
		tax_hash.each do |tax_id, from_to_array|
			if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
				tax=Tax.find(tax_id)
			end
		end
	end
	if tax==nil	
	tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
	end

	tax=tax.basic
	if previous_milestone==nil
		deduction=0
	elsif previous_milestone.flat_value_percentage==nil
		deduction=previous_milestone.amount.to_i
		deduction=deduction/(1+(tax/100))
	else
		deduction=0
	end
	
	if milestone.flat_value_percentage==nil
	    unit=milestone.amount.to_i
	    unit=unit/(1+(tax/100))
	else
	    unit=((((total_flat_amount)*milestone.flat_value_percentage)/100)-deduction).round
	end  
	
	return unit
end

def milestone_plc_basic(milestone_id)
	milestone=Milestone.find(milestone_id)
	if milestone.flat_value_percentage==nil
		plc=0
	else
		plc = (((self.plc_basic+self.flc_basic)*milestone.flat_value_percentage)/100).round
	end
	
	return plc
end

def milestone_parking_basic(milestone_id)
	milestone=Milestone.find(milestone_id)
	@car_parks=[]
	total_parking=0.0
    parking=0.0
    CostSheetCarParking.where(cost_sheet_id: self.id).each do|cost_sheet_car_park_nature|
	  	car_park=CarPark.find_by(car_park_nature_id: cost_sheet_car_park_nature.car_parking_nature_id, business_unit_id: self.flat.block.business_unit_id)
		@car_parks+=[[car_park,cost_sheet_car_park_nature.quantity]]
  	end
  	if @car_parks == []
  		parking_basic=0
  	else
	  	@car_parks.each do |car_park|
	  		parking=(car_park[1]*car_park[0].rate).round
        	total_parking+=parking
	  	end
	end
	if milestone.flat_value_percentage == nil
		return parking_basic=0
	else
		return parking_basic=((total_parking*milestone.flat_value_percentage)/100).round
	end
end

def milestone_edc_basic(milestone_id)
	milestone=Milestone.find(milestone_id)
	extra_development_charges=0
	total_extra_development_charges=0
	ExtraDevelopmentCharge.where(business_unit_id: self.flat.block.business_unit_id, flat_type: self.flat.BHK).each do |extra_development_charge| 
        if extra_development_charge.amount !=nil
           extra_development_charges = extra_development_charge.amount
        elsif extra_development_charge.rate !=nil
            extra_development_charges =((self.flat.SBA)*extra_development_charge.rate).round
        elsif extra_development_charge.percentage != nil
            extra_development_charges =(((self.unit_cost+self.plc_basic+self.flc_basic-self.discount[0]+self.parking[0]+self.servant_quarter)*extra_development_charge.percentage)/100).round
	    end
	    total_extra_development_charges+=extra_development_charges
	end

	if milestone.extra_development_charge_percentage==nil
	  extra=0
	else
	  extra=((total_extra_development_charges*milestone.extra_development_charge_percentage)/100).round
	end
	
	return extra
end

def milestone_gst(milestone_id)
	milestone=Milestone.find(milestone_id)
	tax_hash=Tax.from_to_hash(self.lead.business_unit_id)
	if self.bookings[0]==nil
	tax=Tax.find(tax_hash.keys.last)
	else
		ledger_entry_header=LedgerEntryHeader.includes(:ledger_entry_items).where(:ledger_entry_headers => {booking_id: self.bookings[0].id}, :ledger_entry_items => {milestone_id: milestone_id})
		if ledger_entry_header != []
			demand_date=ledger_entry_header[0].date
			tax_hash.each do |tax_id, from_to_array|
				if demand_date >= from_to_array[0] && demand_date < from_to_array[1]
					tax=Tax.find(tax_id)
				end
			end
		else
			booking_date=self.bookings[0].date
			tax_hash.each do |tax_id, from_to_array|
				if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
					tax=Tax.find(tax_id)
				end
			end
		end	
	end
	if tax==nil	
	tax=Tax.where(business_unit: self.lead.business_unit_id)[0]
	end
	previous_milestone=Milestone.find_by(payment_plan_id: milestone.payment_plan_id, order: milestone.order-1)
	if previous_milestone==nil
		deduction=0
	elsif previous_milestone.flat_value_percentage==nil
		deduction=previous_milestone.amount.to_i
		deduction=deduction/(1+(tax.basic/100))
	else
		deduction=0
	end
	gst_basic=(((self.milestone_unit_basic(milestone.id)+deduction)*(tax.basic/100))+(self.milestone_parking_basic(milestone.id)*(tax.car_park/100))+(self.milestone_edc_basic(milestone.id)*(tax.edc/100))+(self.milestone_plc_basic(milestone.id)*(tax.plc/100))-(deduction*(tax.basic/100))).round

	return gst_basic
end

def total_flat_value
	total_flat_value =  self.unit_gross+self.plc_gross+self.flc_gross+self.edc+self.servant_quarter_gross+self.parking[1]-(self.discount[1].to_f)
	return total_flat_value
end

def total_flat_value_without_gst
	total_parking=0.0
	car_parks = []
	CostSheetCarParking.where(cost_sheet_id: self.id).each do|cost_sheet_car_park_nature|
	  	car_park=CarPark.find_by(car_park_nature_id: cost_sheet_car_park_nature.car_parking_nature_id, business_unit_id: self.flat.block.business_unit_id)
		car_parks+=[[car_park,cost_sheet_car_park_nature.quantity]]
  	end
  	car_parks.each do |car_park|
  		total_parking += (car_park[1]*car_park[0].rate).round
  	end
  	if self.flat.OTA == nil || self.flat.OTA == ''
  		total_flat_value_without_gst = self.unit_cost+self.flc_basic+self.plc_basic+self.servant_quarter_basic+total_parking
  	else
  		total_flat_value_without_gst = self.unit_cost+self.flc_basic+self.plc_basic+self.servant_quarter_basic+self.ota_basic+total_parking
  	end

  	return total_flat_value_without_gst
end

end