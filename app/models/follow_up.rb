class FollowUp < ApplicationRecord
belongs_to :lead
belongs_to :personnel
belongs_to :business_unit
belongs_to :telephony_call
belongs_to :broker_contact
has_one :field_visit
has_one :repeat_visit
# communication_time means when the lead was communicated with
# follow_up_time is the time assigned when followup is to be done, when the lead was communicated with last
# unused fields viz. escalated, hot, follow_up_from

def broker_status
	broker_project_status = BrokerProjectStatus.find_by_broker_id(self.broker_contact.broker_id)
	if broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == true && broker_project_status.site_visited == true && broker_project_status.contract_signed == true
		status = "Contract Signed"
	elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == true && broker_project_status.site_visited == true && broker_project_status.contract_signed == nil
		status = "Site Visited"
	elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == true && broker_project_status.site_visited == nil && broker_project_status.contract_signed == nil
		status = "Hardcopy Sent"
	elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == nil && broker_project_status.site_visited == nil && broker_project_status.contract_signed == nil
		status = "Softcopy Sent"
	elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == nil && broker_project_status.hardcopy_collaterals_sent == nil && broker_project_status.site_visited == nil && broker_project_status.contract_signed == nil
		status = "Contacted"
	else
		status = "In follow up"
	end
	return status
end

def current_status
	 if self.osv == true && self.status == false && self.lead.interested_in_site_visit_on == nil && self.lead.qualified_on != nil
	 	status = 'Qualified'
	 elsif self.osv == true && self.status == false && self.lead.interested_in_site_visit_on != nil 
	 	if  self.created_at < self.lead.interested_in_site_visit_on
	 		status = 'Qualified'
	 	else 	
	 		status = 'Interested in Site Visit'
	 	end
	 elsif self.osv == true
	 	status='OV'
	 elsif self.lead.virtually_visited_on != nil
	 	status = 'Virtually Visited'
	 elsif self.osv== false && self.status==nil# status is nil
	 	status='Negotiation' # repeat site visited
	 elsif self.osv== false && self.status==false# status is nil
	 	status='Field Visited' # repeat site visited
 	 	if FieldVisit.joins(:follow_up).where(:follow_ups => {lead_id: self.lead_id}).where('field_visits.updated_at <= ?', self.created_at+10).count==1
 	 		status='Field Visited on '+FieldVisit.joins(:follow_up).where(:follow_ups => {lead_id: self.lead_id}).where('field_visits.updated_at <= ?', self.created_at+10).last.date.strftime("%d/%m/%y")
 		else
 			status='Repeat Field Visited on '+FieldVisit.joins(:follow_up).where(:follow_ups => {lead_id: self.lead_id}).where('field_visits.updated_at <= ?', self.created_at+10).last.date.strftime("%d/%m/%y")
 		end
	 # osv false and status false - field visit
	 elsif self.osv==nil && self.status==nil
	 	status='In Follow Up'
	 elsif self.osv==nil && self.status==false
	 	if RepeatVisit.where(follow_up_id: self.id)==[]
	 		status='Site Visited on '+self.lead.site_visited_on.strftime("%d/%m/%y")
		else
			status='Repeat Site Visited on '+RepeatVisit.where(follow_up_id: self.id).last.date.strftime("%d/%m/%y")	
	 	end
	 elsif self.osv==nil && self.status==true && self.lead.lost_reason_id==nil && self.lead.follow_ups.find_by(last: true).status==true && self.lead.follow_ups.find_by(last: true).osv==nil
	 	status='Booked'
	 elsif self.osv==nil && self.status==true && self.lead.lost_reason_id==nil
	 	status='Lost, then Reopened'
	 elsif self.osv==nil && self.status==true
	 	status='Lost:' + self.lead.lost_reason.description
	 end
	 return status
end

end
