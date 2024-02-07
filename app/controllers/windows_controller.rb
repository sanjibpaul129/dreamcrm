class WindowsController < ApplicationController
before_action :site_executive_options, only: [:pending_followups, :all_live_leads, :fresh_leads, :followup_history, :followup_due]
skip_before_action :verify_authenticity_token, only: [:call_record_follow_up_entry_form, :personnel_wise_leads_genie]
before_action :require_login, except: [:customer_feedback_form, :customer_feedback_entry] 
   
def mis
	@site_executives = selections_with_all_active(Personnel, :name)
	@projects = selections_with_all(BusinessUnit, :name)
	lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	lost_reasons = lost_reasons-[57,49]
	lost_reasons = lost_reasons+[nil]
	if params[:project]==nil
	projects_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).where.not(name: ['Dream Apartments-HO','Dream Pratham','Dream Channel','Dream Elite'])
	else
		if params[:project][:selected]=='-1'
		projects_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id)
		else
		projects_selected=BusinessUnit.where(id: params[:project][:selected].to_i)
		end
	end
	@projects_selected=projects_selected
	if params[:date]==nil
	@month=Time.now.month
	@year=Time.now.year
	else	
	@month=params[:date][:month].to_i
	@year=params[:date][:year].to_i
	end
	if params[:site_executive]==nil
	@executive=-1
	elsif params[:site_executive][:picked]==-1
	@executive=-1
	else
	@executive=params[:site_executive][:picked].to_i	
	end

	@this_month_beginning=Time.now.beginning_of_month
	@this_month_end=(Time.now.end_of_month)+1.day

	@project_wise_this_months_count=[]

	if @executive==-1
		projects_selected.each do |project_selected|
			leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).count
			qualified_count = Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('qualified_on is not ?', nil ).where('extract(year from leads.qualified_on) = ? AND extract(month from leads.qualified_on) = ?',@year, @month).count
			site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).count
			bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).count
			@project_wise_this_months_count+=[[project_selected.id, leads_generated_count, qualified_count, site_visits_count, 0,0, bookings_count]]
		end
	else
		projects_selected.each do |project_selected|
			leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, lost_reason_id: lost_reasons).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).count
			qualified_count = Lead.joins(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('qualified_on is not ?', nil ).where('extract(year from leads.qualified_on) = ? AND extract(month from leads.qualified_on) = ?',@year, @month).count
			site_visits_count=Lead.joins(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).count
			bookings_count=Lead.joins(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).count
			@project_wise_this_months_count+=[[project_selected.id, leads_generated_count, qualified_count, site_visits_count, 0,0, bookings_count]]
		end
	end

	@one_month_before_beginning=(Time.now-(1.months)).beginning_of_month
	@one_month_before_end=((Time.now-(1.months)).end_of_month)+1.day

	@project_wise_one_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@one_month_before_beginning, @one_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@one_month_before_beginning, @one_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@one_month_before_beginning, @one_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_one_month_before_count+=[[project_selected.id, visit_percentage, booking_percentage, leads_generated_count]]
	end

	@two_month_before_beginning=(Time.now-(2.months)).beginning_of_month
	@two_month_before_end=((Time.now-(2.months)).end_of_month)+1.day

	@project_wise_two_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@two_month_before_beginning, @two_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@two_month_before_beginning, @two_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@two_month_before_beginning, @two_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_two_month_before_count+=[[project_selected.id, visit_percentage, booking_percentage, leads_generated_count]]
	end

	@three_month_before_beginning=(Time.now-(3.months)).beginning_of_month
	@three_month_before_end=((Time.now-(3.months)).end_of_month)+1.day

	@project_wise_three_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@three_month_before_beginning, @three_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@three_month_before_beginning, @three_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@three_month_before_beginning, @three_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_three_month_before_count+=[[project_selected.id, visit_percentage, booking_percentage, leads_generated_count]]
	end

	@four_month_before_beginning=(Time.now-(4.months)).beginning_of_month
	@four_month_before_end=((Time.now-(4.months)).end_of_month)+1.day

	@project_wise_four_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@four_month_before_beginning, @four_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@four_month_before_beginning, @four_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@four_month_before_beginning, @four_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_four_month_before_count+=[[project_selected.id, visit_percentage, booking_percentage, leads_generated_count]]
	end

	@five_month_before_beginning=(Time.now-(5.months)).beginning_of_month
	@five_month_before_end=((Time.now-(5.months)).end_of_month)+1.day

	@project_wise_five_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@five_month_before_beginning, @five_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@five_month_before_beginning, @five_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@five_month_before_beginning, @five_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_five_month_before_count+=[[project_selected.id, visit_percentage, booking_percentage, leads_generated_count]]
	end

	@six_month_before_beginning=(Time.now-(6.months)).beginning_of_month
	@six_month_before_end=((Time.now-(6.months)).end_of_month)+1.day

	@project_wise_six_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@six_month_before_beginning, @six_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@six_month_before_beginning, @six_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@six_month_before_beginning, @six_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_six_month_before_count+=[[project_selected.id, visit_percentage, booking_percentage, leads_generated_count]]
	end

	@project_wise_last_6_months_count = []

	projects_selected.each do |project_selected|
		leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@six_month_before_beginning, @one_month_before_end).count
		qualified_count = Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('qualified_on is not ?', nil ).where('leads.qualified_on >= ? AND leads.qualified_on < ?',@six_month_before_beginning, @one_month_before_end).count
		site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@six_month_before_beginning, @one_month_before_end).count
		bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@six_month_before_beginning, @one_month_before_end).count
		@project_wise_last_6_months_count+=[[project_selected.id, leads_generated_count, qualified_count ,site_visits_count, 0,0, bookings_count]]
	end

end


def mis_genie
	projects_selected=BusinessUnit.where(organisation_id: 1)
	@projects_selected=projects_selected
	@month=Time.now.month
	@year=Time.now.year
	
	@this_month_beginning=Time.now.beginning_of_month
	@this_month_end=(Time.now.end_of_month)+1.day

	@project_wise_this_months_count=[]

		projects_selected.each do |project_selected|
		leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).count
		site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).count
		repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('extract(year from repeat_visits.date) = ? AND extract(month from repeat_visits.date) = ?',@year, @month).count
		field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('extract(year from field_visits.date) = ? AND extract(month from field_visits.date) = ?',@year, @month).count
		bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).count
		@project_wise_this_months_count+=[[project_selected.name, leads_generated_count, site_visits_count, 0,0, bookings_count]]
		end
	
	@one_month_before_beginning=(Time.now-(1.months)).beginning_of_month
	@one_month_before_end=((Time.now-(1.months)).end_of_month)+1.day

	@project_wise_one_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@one_month_before_beginning, @one_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@one_month_before_beginning, @one_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@one_month_before_beginning, @one_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@one_month_before_beginning, @one_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@one_month_before_beginning, @one_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_one_month_before_count+=[[project_selected.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@two_month_before_beginning=(Time.now-(2.months)).beginning_of_month
	@two_month_before_end=((Time.now-(2.months)).end_of_month)+1.day

	@project_wise_two_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@two_month_before_beginning, @two_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@two_month_before_beginning, @two_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@two_month_before_beginning, @two_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@two_month_before_beginning, @two_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@two_month_before_beginning, @two_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_two_month_before_count+=[[project_selected.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@three_month_before_beginning=(Time.now-(3.months)).beginning_of_month
	@three_month_before_end=((Time.now-(3.months)).end_of_month)+1.day

	@project_wise_three_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@three_month_before_beginning, @three_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@three_month_before_beginning, @three_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@three_month_before_beginning, @three_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@three_month_before_beginning, @three_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@three_month_before_beginning, @three_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_three_month_before_count+=[[project_selected.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@four_month_before_beginning=(Time.now-(4.months)).beginning_of_month
	@four_month_before_end=((Time.now-(4.months)).end_of_month)+1.day

	@project_wise_four_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@four_month_before_beginning, @four_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@four_month_before_beginning, @four_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@four_month_before_beginning, @four_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@four_month_before_beginning, @four_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@four_month_before_beginning, @four_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_four_month_before_count+=[[project_selected.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@five_month_before_beginning=(Time.now-(5.months)).beginning_of_month
	@five_month_before_end=((Time.now-(5.months)).end_of_month)+1.day

	@project_wise_five_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@five_month_before_beginning, @five_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@five_month_before_beginning, @five_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@five_month_before_beginning, @five_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@five_month_before_beginning, @five_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@five_month_before_beginning, @five_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_five_month_before_count+=[[project_selected.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@six_month_before_beginning=(Time.now-(6.months)).beginning_of_month
	@six_month_before_end=((Time.now-(6.months)).end_of_month)+1.day

	@project_wise_six_month_before_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@six_month_before_beginning, @six_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@six_month_before_beginning, @six_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@six_month_before_beginning, @six_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@six_month_before_beginning, @six_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@six_month_before_beginning, @six_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@project_wise_six_month_before_count+=[[project_selected.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@project_wise_last_6_months_count=[]

	projects_selected.each do |project_selected|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@six_month_before_beginning, @one_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@six_month_before_beginning, @one_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@six_month_before_beginning, @one_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: 1}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@six_month_before_beginning, @one_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {organisation_id: 1}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@six_month_before_beginning, @one_month_before_end).count
	@project_wise_last_6_months_count+=[[project_selected.name, leads_generated_count, site_visits_count, 0,0, bookings_count]]
	end

end

def executive_wise_mis_genie
	executives=Personnel.where(organisation_id: 1).where('access_right is ? OR access_right = ?', nil, 2)

	@month=Time.now.month
	@year=Time.now.year
	
	@this_month_beginning=Time.now.beginning_of_month
	@this_month_end=(Time.now.end_of_month)+1.day

	@executive_wise_this_months_count=[]

		executives.each do |executive|
		leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).count
		site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).count
		repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('extract(year from repeat_visits.date) = ? AND extract(month from repeat_visits.date) = ?',@year, @month).count
		field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('extract(year from field_visits.date) = ? AND extract(month from field_visits.date) = ?',@year, @month).count
		bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).count
		@executive_wise_this_months_count+=[[executive.name, leads_generated_count, site_visits_count, 0,0, bookings_count]]
		end
	
	@one_month_before_beginning=(Time.now-(1.months)).beginning_of_month
	@one_month_before_end=((Time.now-(1.months)).end_of_month)+1.day

	@executive_wise_one_month_before_count=[]

	executives.each do |executive|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@one_month_before_beginning, @one_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@one_month_before_beginning, @one_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@one_month_before_beginning, @one_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('field_visits.date >= ? AND field_visits.date < ?',@one_month_before_beginning, @one_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@one_month_before_beginning, @one_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@executive_wise_one_month_before_count+=[[executive.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@two_month_before_beginning=(Time.now-(2.months)).beginning_of_month
	@two_month_before_end=((Time.now-(2.months)).end_of_month)+1.day

	@executive_wise_two_month_before_count=[]

	executives.each do |executive|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@two_month_before_beginning, @two_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@two_month_before_beginning, @two_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@two_month_before_beginning, @two_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('field_visits.date >= ? AND field_visits.date < ?',@two_month_before_beginning, @two_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@two_month_before_beginning, @two_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@executive_wise_two_month_before_count+=[[executive.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@three_month_before_beginning=(Time.now-(3.months)).beginning_of_month
	@three_month_before_end=((Time.now-(3.months)).end_of_month)+1.day

	@executive_wise_three_month_before_count=[]

	executives.each do |executive|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@three_month_before_beginning, @three_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@three_month_before_beginning, @three_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@three_month_before_beginning, @three_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('field_visits.date >= ? AND field_visits.date < ?',@three_month_before_beginning, @three_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@three_month_before_beginning, @three_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@executive_wise_three_month_before_count+=[[executive.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@four_month_before_beginning=(Time.now-(4.months)).beginning_of_month
	@four_month_before_end=((Time.now-(4.months)).end_of_month)+1.day

	@executive_wise_four_month_before_count=[]

	executives.each do |executive|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@four_month_before_beginning, @four_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@four_month_before_beginning, @four_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@four_month_before_beginning, @four_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('field_visits.date >= ? AND field_visits.date < ?',@four_month_before_beginning, @four_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@four_month_before_beginning, @four_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@executive_wise_four_month_before_count+=[[executive.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@five_month_before_beginning=(Time.now-(5.months)).beginning_of_month
	@five_month_before_end=((Time.now-(5.months)).end_of_month)+1.day

	@executive_wise_five_month_before_count=[]

	executives.each do |executive|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@five_month_before_beginning, @five_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@five_month_before_beginning, @five_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@five_month_before_beginning, @five_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('field_visits.date >= ? AND field_visits.date < ?',@five_month_before_beginning, @five_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@five_month_before_beginning, @five_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@executive_wise_five_month_before_count+=[[executive.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@six_month_before_beginning=(Time.now-(6.months)).beginning_of_month
	@six_month_before_end=((Time.now-(6.months)).end_of_month)+1.day

	@executive_wise_six_month_before_count=[]

	executives.each do |executive|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@six_month_before_beginning, @six_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@six_month_before_beginning, @six_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@six_month_before_beginning, @six_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('field_visits.date >= ? AND field_visits.date < ?',@six_month_before_beginning, @six_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@six_month_before_beginning, @six_month_before_end).count
		if leads_generated_count==0
		visit_percentage=0
		else
		visit_percentage=((((site_visits_count).to_f)/(leads_generated_count.to_f))*100).round	
		end
		if site_visits_count==0
		booking_percentage=0
		else
		booking_percentage=(((bookings_count.to_f)/((site_visits_count).to_f))*100).round	
		end
	@executive_wise_six_month_before_count+=[[executive.name, visit_percentage, booking_percentage, leads_generated_count, site_visits_count, bookings_count]]
	end

	@executive_wise_last_6_months_count=[]

	executives.each do |executive|
	leads_generated_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@six_month_before_beginning, @one_month_before_end).count
	site_visits_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@six_month_before_beginning, @one_month_before_end).count
	repeat_site_visits_count=RepeatVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@six_month_before_beginning, @one_month_before_end).count
	field_visits_count=FieldVisit.joins(:follow_up => [:personnel, :lead]).where(:personnels => {id: executive.id}).where('field_visits.date >= ? AND field_visits.date < ?',@six_month_before_beginning, @one_month_before_end).count
	bookings_count=Lead.joins(:personnel).where(:personnels => {id: executive.id}).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@six_month_before_beginning, @one_month_before_end).count
	@executive_wise_last_6_months_count+=[[executive.name, leads_generated_count, site_visits_count, 0,0, bookings_count]]
	end

end

def daily_entries
	@from=(Date.today)-30
  	@to=(Date.today)
  	if params[:lead] != nil
    	@from=params[:lead][:from]
    	@to=params[:lead][:to]
  	end
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		project_selected -= [3]
	else
		if params[:project][:selected]=="-1"
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			project_selected -= [3]
		else
			project_selected=params[:project][:selected]
		end
	end
	# if params[:date]==nil
	# @month=Time.now.month
	# year=Time.now.year
	# else	
	# @month=params[:date][:month].to_i
	# year=params[:date][:year].to_i
	# end
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Audit'
		@lead_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		# @qualified_leads=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.qualified_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from, @to).group("leads.personnel_id").count
		@qualified_leads=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.qualified_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from.to_datetime.beginning_of_day, @to.to_datetime+1.day).group("leads.personnel_id").count
		# @isv_leads=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.interested_in_site_visit_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from, @to).group("leads.personnel_id").count
		@isv_leads=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.interested_in_site_visit_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from.to_datetime.beginning_of_day, @to.to_datetime+1.day).group("leads.personnel_id").count
		@fresh_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: true, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: nil, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@lost_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@site_visited_leads=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day)
		@site_visited_entries=@site_visited_leads.group("leads.personnel_id").count
		@repeat_site_visit_entries=RepeatVisit.includes(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@field_visit_entries=FieldVisit.includes(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@booked_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@site_executives=Personnel.where(organisation_id: current_personnel.organisation_id)
		@fresh_call_score=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: true, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").sum("follow_ups.score")
		@followup_score=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: nil, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").sum("follow_ups.score")
		@qualified_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('leads.qualified_on is not ?', nil).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@isv_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('leads.interested_in_site_visit_on is not ?', nil).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count

		@new_fresh_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: true, :leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@new_followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: nil, :leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@new_lost_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@new_site_visited_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@new_booked_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		
		@old_fresh_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: true, :leads => {business_unit_id: project_selected}).where('leads.generated_on < ?', @from).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@old_followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: nil, :leads => {business_unit_id: project_selected}).where('leads.generated_on < ?', @from).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@old_lost_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('leads.generated_on < ?', @from).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@old_site_visited_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.generated_on < ?', @from).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@old_booked_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.generated_on < ?', @from).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		
		@fresh_call_entries_for_delay=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: true, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day)
	
	elsif current_personnel.status=='Team Lead'
		team_members=current_personnel.member_array	
		@lead_entries=Lead.includes(:personnel).where(:personnels => {id: team_members}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		# @qualified_leads=Lead.where(business_unit: project_selected, personnel_id: team_members).where('qualified_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from, @to).group("personnel_id").count
		# @isv_leads=Lead.where(business_unit: project_selected, personnel_id: team_members).where('interested_in_site_visit_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from, @to).group("personnel_id").count
		@qualified_leads=Lead.where(business_unit: project_selected, personnel_id: team_members).where('qualified_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from.to_datetime.beginning_of_day, @to.to_datetime+1.day).group("personnel_id").count
		@isv_leads=Lead.where(business_unit: project_selected, personnel_id: team_members).where('interested_in_site_visit_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from.to_datetime.beginning_of_day, @to.to_datetime+1.day).group("personnel_id").count
		@fresh_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: team_members}, first: true, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: team_members}, first: nil, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@lost_entries=Lead.includes(:personnel).where(:personnels => {id: team_members}, business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@site_visited_leads=Lead.includes(:personnel).where(:personnels => {id: team_members}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day)
		@site_visited_entries=@site_visited_leads.group("leads.personnel_id").count
		@repeat_site_visit_entries=RepeatVisit.includes(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: current_personnel.organisation_id, id: team_members}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@field_visit_entries=FieldVisit.includes(:follow_up => [:personnel, :lead]).where(:personnels => {organisation_id: current_personnel.organisation_id, id: team_members}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@booked_entries=Lead.includes(:personnel).where(:personnels => {id: team_members}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@site_executives=Personnel.where(id: team_members)
		@fresh_call_score=FollowUp.includes(:personnel, :lead).where(:personnels => {id: team_members}, first: true, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").sum("follow_ups.score")
		@followup_score=FollowUp.includes(:personnel, :lead).where(:personnels => {id: team_members}, first: nil, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").sum("follow_ups.score")
		@qualified_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: team_members}, :leads => {business_unit_id: project_selected}).where('leads.qualified_on is not ?', nil).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@isv_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: team_members}, :leads => {business_unit_id: project_selected}).where('leads.interested_in_site_visit_on is not ?', nil).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
	else
		@lead_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('leads.generated_on >= ? AND  leads.generated_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		# @qualified_leads=Lead.where(personnel_id: current_personnel.id, business_unit: project_selected).where('qualified_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from, @to).group("personnel_id").count
		# @isv_leads=Lead.where(personnel_id: current_personnel.id, business_unit: project_selected).where('interested_in_site_visit_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from, @to).group("personnel_id").count
		@qualified_leads=Lead.where(personnel_id: current_personnel.id, business_unit: project_selected).where('qualified_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from.to_datetime.beginning_of_day, @to.to_datetime+1.day).group("personnel_id").count
		@isv_leads=Lead.where(personnel_id: current_personnel.id, business_unit: project_selected).where('interested_in_site_visit_on is not ? AND leads.generated_on >= ? AND leads.generated_on < ?', nil, @from.to_datetime.beginning_of_day, @to.to_datetime+1.day).group("personnel_id").count
		@fresh_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: true, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: nil, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@lost_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where(' leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@site_visited_leads=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('site_visited_on is not ?', nil ).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day)
		@site_visited_entries=@site_visited_leads.group("leads.personnel_id").count
		@repeat_site_visit_entries=RepeatVisit.includes(:follow_up => [:personnel, :lead]).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@field_visit_entries=FieldVisit.includes(:follow_up => [:personnel, :lead]).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@booked_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.personnel_id").count
		@site_executives=Personnel.where(id: current_personnel.id)	
		@fresh_call_score=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: true, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").sum("follow_ups.score")
		@followup_score=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: nil, :leads => {business_unit_id: project_selected}).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").sum("follow_ups.score")
		@qualified_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('leads.qualified_on is not ?', nil).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
		@isv_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('leads.interested_in_site_visit_on is not ?', nil).where('follow_ups.created_at >= ? AND follow_ups.created_at < ?',@from, @to.to_date+1.day).group("follow_ups.personnel_id").count
	end

	personnel_site_visits=[]
	just_previous=false
	tele_marketing_site_visit=nil
	sales_executives_site_visit=nil
	sales_executive_taken=false
	@site_visited_leads.each do |site_visit_lead|
		sales_executive_taken=false
		just_previous=false
		sales_executives_site_visit=nil
		tele_marketing_site_visit=nil
		site_visit_lead.follow_ups.sort_by{|x| [x.communication_time, x.created_at]}.reverse.each do |follow_up|
			if follow_up.personnel.access_right==nil && sales_executive_taken==false
				sales_executives_site_visit=follow_up.personnel
				sales_executive_taken=true
			end
			if (follow_up.status==false && follow_up.osv==nil) || (follow_up.status==nil && follow_up.osv==true) || just_previous==true
				tele_marketing_site_visit=follow_up.personnel
				if just_previous==false
					just_previous=true
				elsif just_previous=true && follow_up.status==false && follow_up.osv==nil
				elsif just_previous=true && follow_up.status==nil && follow_up.osv==true
				else
					just_previous=false
				end
			end
		end
		if site_visit_lead.follow_ups.count == 0
			sales_executives_site_visit = site_visit_lead.personnel if sales_executives_site_visit==nil
			tele_marketing_site_visit = site_visit_lead.personnel if tele_marketing_site_visit == nil
		else
			tele_marketing_site_visit = site_visit_lead.personnel if tele_marketing_site_visit == nil
			sales_executives_site_visit = site_visit_lead.follow_ups.sort_by{|x| [x.communication_time, x.created_at]}.reverse[0].personnel if sales_executives_site_visit==nil
		end
		personnel_site_visits+=[[site_visit_lead, tele_marketing_site_visit, sales_executives_site_visit]]
	end
	@site_visits_organised={}
	@site_visits_received={}
	personnel_site_visits.each do |personnel_site_visit|
		@site_visits_organised[personnel_site_visit[1].id]=(@site_visits_organised[personnel_site_visit[1].id].to_i)+1
		@site_visits_received[personnel_site_visit[2].id]=(@site_visits_received[personnel_site_visit[2].id].to_i)+1
	end
end

def monthly_spend_entry_form
	Lead.where('created_at')
end

def daily_entries_in_a_month
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	else
		if params[:project][:selected]=='-1'
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
		project_selected=params[:project][:selected]
		end
	end
	if params[:date]==nil
		@month=Time.now.month
		@year=Time.now.year
	else	
		@month=params[:date][:month].to_i
		@year=params[:date][:year].to_i
	end
	if params[:site_executive]==nil
		@executive=-1
	elsif params[:site_executive][:picked]==-1
		@executive=-1
	else
		@executive=params[:site_executive][:picked].to_i	
	end	

	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
		if @executive==-1
			@lead_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id},business_unit: project_selected).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@first_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: true, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {organisation_id: current_personnel.organisation_id}, first: nil, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@lost_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id},business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('extract(year from leads.updated_at) = ? AND extract(month from leads.updated_at) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }
			@site_visited_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id},business_unit: project_selected).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).group_by {|entry| entry.site_visited_on.to_date }
			@repeat_site_visit_entries=RepeatVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@field_visit_entries=FieldVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@qualified_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('qualified_on is not ?', nil).group_by {|entry| entry.qualified_on.to_date}
			@isv_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('interested_in_site_visit_on is not ?', nil).group_by {|entry| entry.interested_in_site_visit_on.to_date}
			@booked_entries=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id},business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }
		else
			@lead_entries=Lead.includes(:personnel).where(:personnels => {id: @executive},business_unit: project_selected).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@first_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: @executive}, first: true, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: @executive}, first: nil, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@lost_entries=Lead.includes(:personnel).where(:personnels => {id: @executive},business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('extract(year from leads.updated_at) = ? AND extract(month from leads.updated_at) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }
			@site_visited_entries=Lead.includes(:personnel).where(:personnels => {id: @executive},business_unit: project_selected).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).group_by {|entry| entry.site_visited_on.to_date }
			@repeat_site_visit_entries=RepeatVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {id: @executive}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@field_visit_entries=FieldVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {id: @executive}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
			@qualified_entries=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('qualified_on is not ?', nil).group_by {|entry| entry.qualified_on.to_date}
			@isv_entries=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('interested_in_site_visit_on is not ?', nil).group_by {|entry| entry.interested_in_site_visit_on.to_date }
			@booked_entries=Lead.includes(:personnel).where(:personnels => {id: @executive},business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }	
		end
		@site_executives=selections_with_all_active(Personnel, :name)	
	elsif current_personnel.status=='Team Lead'
		team_members=current_personnel.member_array
		if @executive==-1
			site_executives=team_members
		else
			site_executives=@executive
		end	
		@lead_entries=Lead.includes(:personnel).where(:personnels => {id: site_executives},business_unit: project_selected).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@first_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: site_executives}, first: true, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: site_executives}, first: nil, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@lost_entries=Lead.includes(:personnel).where(:personnels => {id: site_executives},business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('extract(year from leads.updated_at) = ? AND extract(month from leads.updated_at) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }
		@site_visited_entries=Lead.includes(:personnel).where(:personnels => {id: site_executives},business_unit: project_selected).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).group_by {|entry| entry.site_visited_on.to_date }
		@repeat_site_visit_entries=RepeatVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {id: site_executives}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@field_visit_entries=FieldVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {id: site_executives}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@qualified_entries=Lead.includes(:personnel).where(:personnels => {id: site_executives},business_unit: project_selected).where('qualified_on is not ?', nil).group_by {|entry| entry.qualified_on.to_date }
		@isv_entries=Lead.includes(:personnel).where(:personnels => {id: site_executives},business_unit: project_selected).where('interested_in_site_visit_on is not ?', nil).group_by {|entry| entry.interested_in_site_visit_on.to_date }
		@booked_entries=Lead.includes(:personnel).where(:personnels => {id: site_executives},business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }
		@site_executives=[['All', -1]]
		team_members.each do |team_member|
			@site_executives=@site_executives+[[Personnel.find(team_member).name, team_member]]	
		end
	else
		@lead_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id},business_unit: project_selected).where('extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@first_call_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: true, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@followup_entries=FollowUp.includes(:personnel, :lead).where(:personnels => {id: current_personnel.id}, first: nil, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@lost_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id},business_unit: project_selected).where('status = ? AND lost_reason_id is not ?', true, nil ).where('extract(year from leads.updated_at) = ? AND extract(month from leads.updated_at) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }
		@site_visited_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id},business_unit: project_selected).where('site_visited_on is not ?', nil ).where('extract(year from leads.site_visited_on) = ? AND extract(month from leads.site_visited_on) = ?',@year, @month).group_by {|entry| entry.site_visited_on.to_date }
		@repeat_site_visit_entries=RepeatVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@field_visit_entries=FieldVisit.includes(:follow_up =>[:personnel, :lead]).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('extract(year from follow_ups.created_at) = ? AND extract(month from follow_ups.created_at) = ?',@year, @month).group_by {|entry| entry.created_at.to_date }
		@qualified_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('leads.qualified_on is not ?', nil).group_by {|entry| entry.qualified_on.to_date }
		@isv_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('leads.interested_in_site_visit_on is not ?', nil).group_by {|entry| entry.interested_in_site_visit_on.to_date }
		@booked_entries=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id},business_unit: project_selected).where('status = ? AND lost_reason_id is ?', true, nil ).where('extract(year from leads.booked_on) = ? AND extract(month from leads.booked_on) = ?',@year, @month).group_by {|entry| entry.updated_at.to_date }
		@site_executives=[['All', -1]]
	end
end

def source_wise_leads
	@from=(Date.today)-30
  	@to=(Date.today)
  	if params[:lead] != nil
    	@from=params[:lead][:from]
    	@to=params[:lead][:to]
  	end
	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		@business_unit_id = "-1"
	else
		if params[:project][:selected] == "-1"
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			@business_unit_id = "-1"
		else
			project_selected=params[:project][:selected]
			@business_unit_id=project_selected
		end
	end 
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
		@site_executives=selections_with_all_active(Personnel, :name)
		if params[:site_executive]==nil
			@executive=-1
		elsif params[:site_executive][:picked]==-1
			@executive=-1
		else
			@executive=params[:site_executive][:picked].to_i	
		end
		if @executive==-1	
			@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		else
			@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		end		
	else
		@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
		@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
		@site_visited=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@booked=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@leads_lost=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
	end
	@site_visited_leads_from_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id")
	@site_visited_from_leads_generated=@site_visited_leads_from_generated.count
	@booked_leads_from_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true).group("leads.source_category_id")
	@booked_from_leads_generated=@booked_leads_from_generated.count
	@lost_leads_from_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id")
	@lost_from_leads_generated=@lost_leads_from_generated.count
	@qualified_from_leads_generated=@leads_generated_raw.where.not(qualified_on: nil).group("leads.source_category_id")
	@qualified_leads_from_generated=@qualified_from_leads_generated.count
	@isv_from_leads_generated=@leads_generated_raw.where.not(interested_in_site_visit_on: nil).group("leads.source_category_id")
	@isv_leads_from_generated=@isv_from_leads_generated.count
end


def facebook_leads_expandable
	@from=(Date.today)-30
  	@to=(Date.today)
  	if params[:lead] != nil
    	@from=params[:lead][:from]
    	@to=params[:lead][:to]
  	end
	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
	if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
		@projects=[]
		BusinessUnit.where(organisation_id: 1).each do |business_unit|
			if business_unit.name == "Dream Gurukul"
				@projects += [[business_unit.name, business_unit.id]]
			end
		end
	else
		@projects=selections_with_all(BusinessUnit, :name)
	end
	if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		@business_unit_id = "-1"
	else
		if params[:project][:selected] == "-1"
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			@business_unit_id = "-1"
		else
			project_selected=params[:project][:selected]
			@business_unit_id=project_selected
		end
	end
	
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
		@site_executives=selections_with_all_active(Personnel, :name)
		if params[:site_executive]==nil
			@executive=-1
		elsif params[:site_executive][:picked]==-1
			@executive=-1
		else
			@executive=params[:site_executive][:picked].to_i	
		end
		if @executive==-1	
			@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		else
			@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		end		
	else
		@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
		@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
		@site_visited=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@booked=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@leads_lost=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
	end
	@site_visited_from_leads_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id").count
	@booked_from_leads_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true).group("leads.source_category_id").count
	@lost_from_leads_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id").count
	@qualified_from_leads_generated=@leads_generated_raw.where.not(qualified_on: nil).group('leads.source_category_id').count
	@isv_from_leads_generated=@leads_generated_raw.where.not(interested_in_site_visit_on: nil).group('leads.source_category_id').count
	
	all_sources=@leads_generated.merge(@site_visited).merge(@booked).merge(@leads_lost)
	all_sources=all_sources.keys.uniq
	
	@source_tree={}
	successors=[]
	successor_chain=0
	all_sources.each do |source|
	  if @leads_generated[source]==nil
	    leads_generated=0
	  else
	    leads_generated=@leads_generated[source]
	  end
	  if @site_visited[source]==nil
	    site_visited=0
	  else
	    site_visited=@site_visited[source]
	  end
	  if @booked[source]==nil
	    booked=0
	  else
	    booked=@booked[source]
	  end
	  if @leads_lost[source]==nil
	    leads_lost=0
	  else
	    leads_lost=@leads_lost[source]
	  end
	  if @site_visited_from_leads_generated[source]==nil
	    site_visited_from_leads_generated=0
	  else
	    site_visited_from_leads_generated=@site_visited_from_leads_generated[source]
	  end
	  if @booked_from_leads_generated[source]==nil
	    booked_from_leads_generated=0
	  else
	    booked_from_leads_generated=@booked_from_leads_generated[source]
	  end
	  if @lost_from_leads_generated[source]==nil
	    lost_from_leads_generated=0
	  else
	    lost_from_leads_generated=@lost_from_leads_generated[source]
	  end
	  if @qualified_from_leads_generated[source]==nil
	  	qualified_leads_from_generated=0
	  else
	  	qualified_leads_from_generated=@qualified_from_leads_generated[source]
	  end
	  if @isv_from_leads_generated[source]==nil
	  	isv_leads_from_generated=0
	  else
	  	isv_leads_from_generated=@isv_from_leads_generated[source]
	  end

	  predecessor_id=@sources.find(source).predecessor
	  successors=[]
	  if predecessor_id==nil && @source_tree[source]==nil
	    @source_tree[source]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated,qualified_leads_from_generated,qualified_leads_from_generated,isv_leads_from_generated,isv_leads_from_generated]
	  elsif predecessor_id==nil
	  	@source_tree[source][1]=leads_generated
	  	@source_tree[source][4]=site_visited
	  	@source_tree[source][6]=booked
	  	@source_tree[source][8]=leads_lost
	  	@source_tree[source][10]=site_visited_from_leads_generated
	  	@source_tree[source][12]=booked_from_leads_generated
	  	@source_tree[source][14]=lost_from_leads_generated
	  	@source_tree[source][16]=qualified_leads_from_generated
	  	@source_tree[source][18]=isv_leads_from_generated
	  else
	    successors+=[source]
	    until predecessor_id==nil do
	      predecessor=@sources.find(predecessor_id) 
	      successors+=[predecessor_id]
	      predecessor_id=predecessor.predecessor
	    end
	    successors=successors.reverse
	    successor_chain=nil
	    @source=source
	    successors.each do |successor|
	      if successor==successors.first
	        if @source_tree[successor]==nil
	          @source_tree[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]  
	        else
	          @source_tree[successor][0]=@source_tree[successor][0]+leads_generated
	          @source_tree[successor][3]=@source_tree[successor][3]+site_visited
	          @source_tree[successor][5]=@source_tree[successor][5]+booked
	          @source_tree[successor][7]=@source_tree[successor][7]+leads_lost
	          @source_tree[successor][9]=@source_tree[successor][9]+site_visited_from_leads_generated
	          @source_tree[successor][11]=@source_tree[successor][11]+booked_from_leads_generated
	          @source_tree[successor][13]=@source_tree[successor][13]+lost_from_leads_generated
	          @source_tree[successor][15]=@source_tree[successor][15]+qualified_leads_from_generated
	          @source_tree[successor][17]=@source_tree[successor][17]+isv_leads_from_generated
	        end
	      successor_chain=@source_tree[successor][2]
	      else
	        if successor_chain[successor]==nil
	        	if successor==successors.last
	          		successor_chain[successor]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated, qualified_leads_from_generated, qualified_leads_from_generated, isv_leads_from_generated, isv_leads_from_generated]
	        	else
	        		successor_chain[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]
	        	end
	        else
	          successor_chain[successor][0]=successor_chain[successor][0]+leads_generated
	          successor_chain[successor][3]=successor_chain[successor][3]+site_visited
	          successor_chain[successor][5]=successor_chain[successor][5]+booked
	          successor_chain[successor][7]=successor_chain[successor][7]+leads_lost
	          successor_chain[successor][9]=successor_chain[successor][9]+site_visited_from_leads_generated
	          successor_chain[successor][11]=successor_chain[successor][11]+booked_from_leads_generated
	          successor_chain[successor][13]=successor_chain[successor][13]+lost_from_leads_generated  
	          successor_chain[successor][15]=successor_chain[successor][15]+qualified_leads_from_generated  
	          successor_chain[successor][17]=successor_chain[successor][17]+isv_leads_from_generated  
	        end
	      successor_chain=successor_chain[successor][2]
	      end
	    end  
	  end
	end
	@source_tree=Hash[@source_tree.sort_by{|k, v| v[0]}.reverse]
end

def source_wise_leads_expandable
	@from=(Date.today)-30
  	@to=(Date.today)
  	if params[:lead] != nil
    	@from=params[:lead][:from]
    	@to=params[:lead][:to]
  	end

	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
	
	if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
		@projects=[]
		BusinessUnit.where(organisation_id: 1).each do |business_unit|
			if business_unit.name == "Dream Gurukul"
				@projects += [[business_unit.name, business_unit.id]]
			end
		end
	else
		@projects=selections_with_all(BusinessUnit, :name)
	end
	if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		@business_unit_id = "-1"
	else
		if params[:project][:selected] == "-1"
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			@business_unit_id = "-1"
		else
			project_selected=params[:project][:selected]
			@business_unit_id=project_selected
		end
	end
	
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
		@site_executives=selections_with_all_active(Personnel, :name)
		if params[:site_executive]==nil
			@executive=-1
		elsif params[:site_executive][:picked]==-1
			@executive=-1
		else
			@executive=params[:site_executive][:picked].to_i	
		end
		if @executive==-1	
			@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		else
			@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {id: @executive}, :leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		end		
	else
		@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
		@leads_generated = @leads_generated_raw.group("leads.source_category_id").count
		@site_visited=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@booked=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@leads_lost=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
	end
	@site_visited_from_leads_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id").count
	@booked_from_leads_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true).group("leads.source_category_id").count
	@lost_from_leads_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id").count
	@qualified_from_leads_generated=@leads_generated_raw.where.not(qualified_on: nil).group('leads.source_category_id').count
	@isv_from_leads_generated=@leads_generated_raw.where.not(interested_in_site_visit_on: nil).group('leads.source_category_id').count
	
	all_sources=@leads_generated.merge(@site_visited).merge(@booked).merge(@leads_lost)
	all_sources=all_sources.keys.uniq
	
	@source_tree={}
	successors=[]
	successor_chain=0
	all_sources.each do |source|
	  if @leads_generated[source]==nil
	    leads_generated=0
	  else
	    leads_generated=@leads_generated[source]
	  end
	  if @site_visited[source]==nil
	    site_visited=0
	  else
	    site_visited=@site_visited[source]
	  end
	  if @booked[source]==nil
	    booked=0
	  else
	    booked=@booked[source]
	  end
	  if @leads_lost[source]==nil
	    leads_lost=0
	  else
	    leads_lost=@leads_lost[source]
	  end
	  if @site_visited_from_leads_generated[source]==nil
	    site_visited_from_leads_generated=0
	  else
	    site_visited_from_leads_generated=@site_visited_from_leads_generated[source]
	  end
	  if @booked_from_leads_generated[source]==nil
	    booked_from_leads_generated=0
	  else
	    booked_from_leads_generated=@booked_from_leads_generated[source]
	  end
	  if @lost_from_leads_generated[source]==nil
	    lost_from_leads_generated=0
	  else
	    lost_from_leads_generated=@lost_from_leads_generated[source]
	  end
	  if @qualified_from_leads_generated[source]==nil
	  	qualified_leads_from_generated=0
	  else
	  	qualified_leads_from_generated=@qualified_from_leads_generated[source]
	  end
	  if @isv_from_leads_generated[source]==nil
	  	isv_leads_from_generated=0
	  else
	  	isv_leads_from_generated=@isv_from_leads_generated[source]
	  end

	  predecessor_id=@sources.find(source).predecessor
	  successors=[]
	  if predecessor_id==nil && @source_tree[source]==nil
	    @source_tree[source]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated,qualified_leads_from_generated,qualified_leads_from_generated,isv_leads_from_generated,isv_leads_from_generated]
	  elsif predecessor_id==nil
	  	@source_tree[source][1]=leads_generated
	  	@source_tree[source][4]=site_visited
	  	@source_tree[source][6]=booked
	  	@source_tree[source][8]=leads_lost
	  	@source_tree[source][10]=site_visited_from_leads_generated
	  	@source_tree[source][12]=booked_from_leads_generated
	  	@source_tree[source][14]=lost_from_leads_generated
	  	@source_tree[source][16]=qualified_leads_from_generated
	  	@source_tree[source][18]=isv_leads_from_generated
	  else
	    successors+=[source]
	    until predecessor_id==nil do
	      predecessor=@sources.find(predecessor_id) 
	      successors+=[predecessor_id]
	      predecessor_id=predecessor.predecessor
	    end
	    successors=successors.reverse
	    successor_chain=nil
	    @source=source
	    successors.each do |successor|
	      if successor==successors.first
	        if @source_tree[successor]==nil
	          @source_tree[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]  
	        else
	          @source_tree[successor][0]=@source_tree[successor][0]+leads_generated
	          @source_tree[successor][3]=@source_tree[successor][3]+site_visited
	          @source_tree[successor][5]=@source_tree[successor][5]+booked
	          @source_tree[successor][7]=@source_tree[successor][7]+leads_lost
	          @source_tree[successor][9]=@source_tree[successor][9]+site_visited_from_leads_generated
	          @source_tree[successor][11]=@source_tree[successor][11]+booked_from_leads_generated
	          @source_tree[successor][13]=@source_tree[successor][13]+lost_from_leads_generated
	          @source_tree[successor][15]=@source_tree[successor][15]+qualified_leads_from_generated
	          @source_tree[successor][17]=@source_tree[successor][17]+isv_leads_from_generated
	        end
	      successor_chain=@source_tree[successor][2]
	      else
	        if successor_chain[successor]==nil
	        	if successor==successors.last
	          		successor_chain[successor]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated, qualified_leads_from_generated, qualified_leads_from_generated, isv_leads_from_generated, isv_leads_from_generated]
	        	else
	        		successor_chain[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]
	        	end
	        else
	          successor_chain[successor][0]=successor_chain[successor][0]+leads_generated
	          successor_chain[successor][3]=successor_chain[successor][3]+site_visited
	          successor_chain[successor][5]=successor_chain[successor][5]+booked
	          successor_chain[successor][7]=successor_chain[successor][7]+leads_lost
	          successor_chain[successor][9]=successor_chain[successor][9]+site_visited_from_leads_generated
	          successor_chain[successor][11]=successor_chain[successor][11]+booked_from_leads_generated
	          successor_chain[successor][13]=successor_chain[successor][13]+lost_from_leads_generated  
	          successor_chain[successor][15]=successor_chain[successor][15]+qualified_leads_from_generated  
	          successor_chain[successor][17]=successor_chain[successor][17]+isv_leads_from_generated  
	        end
	      successor_chain=successor_chain[successor][2]
	      end
	    end  
	  end
	end
	@source_tree=Hash[@source_tree.sort_by{|k, v| v[0]}.reverse]


	if current_personnel.email=='rima.bhadra@techshu.in'

	@new_source_tree={}

	@new_source_tree[@source_tree.first[0]]=@source_tree.first[1] 

	@source_tree=@new_source_tree

	end



end

def source_wise_leads_expandable_pure
	@from = (Date.today)-30
  	@to = (Date.today)
  	if params[:lead] != nil
    	@from=params[:lead][:from]
    	@to=params[:lead][:to]
  	end
	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
	lost_reasons=LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	lost_reasons=lost_reasons-[57,49]
	lost_reasons=lost_reasons+[nil]
	if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
		@projects=[]
		BusinessUnit.where(organisation_id: 1).each do |business_unit|
			if business_unit.name == "Dream Gurukul"
				@projects += [[business_unit.name, business_unit.id]]
			end
		end
	else
		@projects=selections_with_all(BusinessUnit, :name)
	end
	if params[:project]==nil
		if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
		project_selected=[70]
		@business_unit_id = 70
		else
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		@business_unit_id = "-1"
		end
	else
		if params[:project][:selected] == "-1"
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			@business_unit_id = "-1"
		else
			project_selected=params[:project][:selected]
			@business_unit_id=project_selected
		end
	end
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead' || current_personnel.status=='Audit'
		@site_executives=selections_with_all_active(Personnel, :name)
		if params[:site_executive]==nil
			@executive=-1
		elsif params[:site_executive][:picked]==-1
			@executive=-1
		else
			@executive=params[:site_executive][:picked].to_i	
		end
		if @executive==-1	
			@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where(lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',(@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@qualified = Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected,lost_reason_id: lost_reasons).where.not(qualified_on: nil).where('leads.qualified_on >= ? AND leads.qualified_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@site_visited = Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected,lost_reason_id: lost_reasons).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked = Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: nil, status: true, cancelled_on: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, status: true).where.not(lost_reason_id: [nil]).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		else
			@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {id: @executive}, :leads => {business_unit_id: project_selected}).where(lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@qualified=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(qualified_on: nil).where('leads.qualified_on >= ? AND leads.qualified_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, lost_reason_id: nil, status: true, cancelled_on: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		end		
	else
		@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?',(@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day)
		@leads_generated = @leads_generated_raw.group("leads.source_category_id").count
		@qualified=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(qualified_on: nil).where('leads.qualified_on >= ? AND leads.qualified_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@site_visited=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@booked=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, lost_reason_id: nil, status: true, cancelled_on: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@leads_lost=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
	end
	@site_visited_from_leads_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id").count
	@booked_from_leads_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true, cancelled_on: nil).group("leads.source_category_id").count
	@lost_from_leads_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id").count
	@qualified_from_leads_generated=@leads_generated_raw.where.not(qualified_on: nil).group('leads.source_category_id').count
	@isv_from_leads_generated=@leads_generated_raw.where.not(interested_in_site_visit_on: nil).group('leads.source_category_id').count
	all_sources=@leads_generated.merge(@qualified).merge(@site_visited).merge(@booked).merge(@leads_lost)
	all_sources=all_sources.keys.uniq
	@source_tree={}
	successors=[]
	successor_chain=0
	all_sources.each do |source|
	  if @leads_generated[source]==nil
	    leads_generated=0
	  else
	    leads_generated=@leads_generated[source]
	  end
	  if @qualified[source]==nil
	    qualified=0
	  else
	    qualified=@qualified[source]
	  end
	  if @site_visited[source]==nil
	    site_visited=0
	  else
	    site_visited=@site_visited[source]
	  end
	  if @booked[source]==nil
	    booked=0
	  else
	    booked=@booked[source]
	  end
	  if @leads_lost[source]==nil
	    leads_lost=0
	  else
	    leads_lost=@leads_lost[source]
	  end
	  if @site_visited_from_leads_generated[source]==nil
	    site_visited_from_leads_generated=0
	  else
	    site_visited_from_leads_generated=@site_visited_from_leads_generated[source]
	  end
	  if @booked_from_leads_generated[source]==nil
	    booked_from_leads_generated=0
	  else
	    booked_from_leads_generated=@booked_from_leads_generated[source]
	  end
	  if @lost_from_leads_generated[source]==nil
	    lost_from_leads_generated=0
	  else
	    lost_from_leads_generated=@lost_from_leads_generated[source]
	  end
	  if @qualified_from_leads_generated[source]==nil
	  	qualified_leads_from_generated=0
	  else
	  	qualified_leads_from_generated=@qualified_from_leads_generated[source]
	  end
	  if @isv_from_leads_generated[source]==nil
	  	isv_leads_from_generated=0
	  else
	  	isv_leads_from_generated=@isv_from_leads_generated[source]
	  end

	  predecessor_id=@sources.find(source).predecessor
	  successors=[]
	  if predecessor_id==nil && @source_tree[source]==nil
	    @source_tree[source]=[leads_generated,leads_generated,{},qualified, qualified, site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated,qualified_leads_from_generated,qualified_leads_from_generated,isv_leads_from_generated,isv_leads_from_generated]
	  elsif predecessor_id==nil
	  	@source_tree[source][1]=leads_generated
	  	@source_tree[source][4]=qualified
	  	@source_tree[source][6]=site_visited
	  	@source_tree[source][8]=booked
	  	@source_tree[source][10]=leads_lost
	  	@source_tree[source][12]=site_visited_from_leads_generated
	  	@source_tree[source][14]=booked_from_leads_generated
	  	@source_tree[source][16]=lost_from_leads_generated
	  	@source_tree[source][18]=qualified_leads_from_generated
	  	@source_tree[source][20]=isv_leads_from_generated
	  else
	    successors+=[source]
	    until predecessor_id==nil do
	      predecessor=@sources.find(predecessor_id) 
	      successors+=[predecessor_id]
	      predecessor_id=predecessor.predecessor
	    end
	    successors=successors.reverse
	    successor_chain=nil
	    @source=source
	    successors.each do |successor|
	      if successor==successors.first
	        if @source_tree[successor]==nil
	          @source_tree[successor]=[leads_generated,0,{},qualified,0,site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]  
	        else
	          @source_tree[successor][0]=@source_tree[successor][0]+leads_generated
	          @source_tree[successor][3]=@source_tree[successor][3]+qualified
	          @source_tree[successor][5]=@source_tree[successor][5]+site_visited
	          @source_tree[successor][7]=@source_tree[successor][7]+booked
	          @source_tree[successor][9]=@source_tree[successor][9]+leads_lost
	          @source_tree[successor][11]=@source_tree[successor][11]+site_visited_from_leads_generated
	          @source_tree[successor][13]=@source_tree[successor][13]+booked_from_leads_generated
	          @source_tree[successor][15]=@source_tree[successor][15]+lost_from_leads_generated
	          @source_tree[successor][17]=@source_tree[successor][17]+qualified_leads_from_generated
	          @source_tree[successor][19]=@source_tree[successor][19]+isv_leads_from_generated
	        end
	      successor_chain=@source_tree[successor][2]
	      else
	        if successor_chain[successor]==nil
	        	if successor==successors.last
	          		successor_chain[successor]=[leads_generated,leads_generated,{},qualified, qualified, site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated, qualified_leads_from_generated, qualified_leads_from_generated, isv_leads_from_generated, isv_leads_from_generated]
	        	else
	        		successor_chain[successor]=[leads_generated,0,{},qualified,0, site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]
	        	end
	        else
	          successor_chain[successor][0]=successor_chain[successor][0]+leads_generated
	          successor_chain[successor][3]=successor_chain[successor][3]+qualified
	          successor_chain[successor][5]=successor_chain[successor][5]+site_visited
	          successor_chain[successor][7]=successor_chain[successor][7]+booked
	          successor_chain[successor][9]=successor_chain[successor][9]+leads_lost
	          successor_chain[successor][11]=successor_chain[successor][11]+site_visited_from_leads_generated
	          successor_chain[successor][13]=successor_chain[successor][13]+booked_from_leads_generated
	          successor_chain[successor][15]=successor_chain[successor][15]+lost_from_leads_generated  
	          successor_chain[successor][17]=successor_chain[successor][17]+qualified_leads_from_generated  
	          successor_chain[successor][19]=successor_chain[successor][19]+isv_leads_from_generated  
	        end
	      successor_chain=successor_chain[successor][2]
	      end
	    end  
	  end
	end
	@source_tree=Hash[@source_tree.sort_by{|k, v| v[0]}.reverse]
	if current_personnel.email=='rima.bhadra@techshu.in'
		@new_source_tree={}
		@new_source_tree[@source_tree.first[0]]=@source_tree.first[1] 
		@source_tree=@new_source_tree
	end
end

# def source_wise_leads_expandable_pure
# 	@from=(Date.today)-30
#   	@to=(Date.today)
#   	if params[:lead] != nil
#     	@from=params[:lead][:from]
#     	@to=params[:lead][:to]
#   	end

# 	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)

# 	lost_reasons=LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
# 	lost_reasons=lost_reasons-[57,49]
# 	lost_reasons=lost_reasons+[nil]
	
# 	if current_personnel.email == "nitesh.m@orangesoftech.net"
# 		@projects=[]
# 		BusinessUnit.where(organisation_id: 1).each do |business_unit|
# 			if business_unit.name == "Dream World City" || business_unit.name == "Dream Valley" || business_unit.name == "Dream One" || business_unit.name == "Dream One Hotel Apartment" || business_unit.name == "Dream Eco City" || business_unit.name == "Ecocity Bungalows"
# 				@projects += [[business_unit.name, business_unit.id]]
# 			end
# 		end
# 	else
# 		@projects=selections_with_all(BusinessUnit, :name)
# 	end
# 	if params[:project]==nil
# 		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
# 		@business_unit_id = "-1"
# 	else
# 		if params[:project][:selected] == "-1"
# 			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
# 			@business_unit_id = "-1"
# 		else
# 			project_selected=params[:project][:selected]
# 			@business_unit_id=project_selected
# 		end
# 	end
	
# 	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
# 		@site_executives=selections_with_all_active(Personnel, :name)
# 		if params[:site_executive]==nil
# 			@executive=-1
# 		elsif params[:site_executive][:picked]==-1
# 			@executive=-1
# 		else
# 			@executive=params[:site_executive][:picked].to_i	
# 		end
# 		if @executive==-1	
# 			@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where(lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
# 			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
# 			@site_visited=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 			@booked=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 			@leads_lost=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 		else
# 			@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {id: @executive}, :leads => {business_unit_id: project_selected}).where(lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
# 			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
# 			@site_visited=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 			@booked=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 			@leads_lost=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 		end		
# 	else
# 		@leads_generated_raw = Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, :leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
# 		@leads_generated = @leads_generated_raw.group("leads.source_category_id").count
# 		@site_visited=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 		@booked=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 		@leads_lost=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
# 	end
# 	@site_visited_from_leads_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id").count
# 	@booked_from_leads_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true).group("leads.source_category_id").count
# 	@lost_from_leads_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id").count
# 	@qualified_from_leads_generated=@leads_generated_raw.where.not(qualified_on: nil).group('leads.source_category_id').count
# 	@isv_from_leads_generated=@leads_generated_raw.where.not(interested_in_site_visit_on: nil).group('leads.source_category_id').count
	
# 	all_sources=@leads_generated.merge(@site_visited).merge(@booked).merge(@leads_lost)
# 	all_sources=all_sources.keys.uniq
	
# 	@source_tree={}
# 	successors=[]
# 	successor_chain=0
# 	all_sources.each do |source|
# 	  if @leads_generated[source]==nil
# 	    leads_generated=0
# 	  else
# 	    leads_generated=@leads_generated[source]
# 	  end
# 	  if @site_visited[source]==nil
# 	    site_visited=0
# 	  else
# 	    site_visited=@site_visited[source]
# 	  end
# 	  if @booked[source]==nil
# 	    booked=0
# 	  else
# 	    booked=@booked[source]
# 	  end
# 	  if @leads_lost[source]==nil
# 	    leads_lost=0
# 	  else
# 	    leads_lost=@leads_lost[source]
# 	  end
# 	  if @site_visited_from_leads_generated[source]==nil
# 	    site_visited_from_leads_generated=0
# 	  else
# 	    site_visited_from_leads_generated=@site_visited_from_leads_generated[source]
# 	  end
# 	  if @booked_from_leads_generated[source]==nil
# 	    booked_from_leads_generated=0
# 	  else
# 	    booked_from_leads_generated=@booked_from_leads_generated[source]
# 	  end
# 	  if @lost_from_leads_generated[source]==nil
# 	    lost_from_leads_generated=0
# 	  else
# 	    lost_from_leads_generated=@lost_from_leads_generated[source]
# 	  end
# 	  if @qualified_from_leads_generated[source]==nil
# 	  	qualified_leads_from_generated=0
# 	  else
# 	  	qualified_leads_from_generated=@qualified_from_leads_generated[source]
# 	  end
# 	  if @isv_from_leads_generated[source]==nil
# 	  	isv_leads_from_generated=0
# 	  else
# 	  	isv_leads_from_generated=@isv_from_leads_generated[source]
# 	  end

# 	  predecessor_id=@sources.find(source).predecessor
# 	  successors=[]
# 	  if predecessor_id==nil && @source_tree[source]==nil
# 	    @source_tree[source]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated,qualified_leads_from_generated,qualified_leads_from_generated,isv_leads_from_generated,isv_leads_from_generated]
# 	  elsif predecessor_id==nil
# 	  	@source_tree[source][1]=leads_generated
# 	  	@source_tree[source][4]=site_visited
# 	  	@source_tree[source][6]=booked
# 	  	@source_tree[source][8]=leads_lost
# 	  	@source_tree[source][10]=site_visited_from_leads_generated
# 	  	@source_tree[source][12]=booked_from_leads_generated
# 	  	@source_tree[source][14]=lost_from_leads_generated
# 	  	@source_tree[source][16]=qualified_leads_from_generated
# 	  	@source_tree[source][18]=isv_leads_from_generated
# 	  else
# 	    successors+=[source]
# 	    until predecessor_id==nil do
# 	      predecessor=@sources.find(predecessor_id) 
# 	      successors+=[predecessor_id]
# 	      predecessor_id=predecessor.predecessor
# 	    end
# 	    successors=successors.reverse
# 	    successor_chain=nil
# 	    @source=source
# 	    successors.each do |successor|
# 	      if successor==successors.first
# 	        if @source_tree[successor]==nil
# 	          @source_tree[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]  
# 	        else
# 	          @source_tree[successor][0]=@source_tree[successor][0]+leads_generated
# 	          @source_tree[successor][3]=@source_tree[successor][3]+site_visited
# 	          @source_tree[successor][5]=@source_tree[successor][5]+booked
# 	          @source_tree[successor][7]=@source_tree[successor][7]+leads_lost
# 	          @source_tree[successor][9]=@source_tree[successor][9]+site_visited_from_leads_generated
# 	          @source_tree[successor][11]=@source_tree[successor][11]+booked_from_leads_generated
# 	          @source_tree[successor][13]=@source_tree[successor][13]+lost_from_leads_generated
# 	          @source_tree[successor][15]=@source_tree[successor][15]+qualified_leads_from_generated
# 	          @source_tree[successor][17]=@source_tree[successor][17]+isv_leads_from_generated
# 	        end
# 	      successor_chain=@source_tree[successor][2]
# 	      else
# 	        if successor_chain[successor]==nil
# 	        	if successor==successors.last
# 	          		successor_chain[successor]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated, qualified_leads_from_generated, qualified_leads_from_generated, isv_leads_from_generated, isv_leads_from_generated]
# 	        	else
# 	        		successor_chain[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]
# 	        	end
# 	        else
# 	          successor_chain[successor][0]=successor_chain[successor][0]+leads_generated
# 	          successor_chain[successor][3]=successor_chain[successor][3]+site_visited
# 	          successor_chain[successor][5]=successor_chain[successor][5]+booked
# 	          successor_chain[successor][7]=successor_chain[successor][7]+leads_lost
# 	          successor_chain[successor][9]=successor_chain[successor][9]+site_visited_from_leads_generated
# 	          successor_chain[successor][11]=successor_chain[successor][11]+booked_from_leads_generated
# 	          successor_chain[successor][13]=successor_chain[successor][13]+lost_from_leads_generated  
# 	          successor_chain[successor][15]=successor_chain[successor][15]+qualified_leads_from_generated  
# 	          successor_chain[successor][17]=successor_chain[successor][17]+isv_leads_from_generated  
# 	        end
# 	      successor_chain=successor_chain[successor][2]
# 	      end
# 	    end  
# 	  end
# 	end
# 	@source_tree=Hash[@source_tree.sort_by{|k, v| v[0]}.reverse]
# 	if current_personnel.email=='rima.bhadra@techshu.in'
# 		@new_source_tree={}
# 		@new_source_tree[@source_tree.first[0]]=@source_tree.first[1] 
# 		@source_tree=@new_source_tree
# 	end
# end

def weekly_source_wise_leads
	if current_personnel.business_unit.organisation_id == 1
		@projects = selections_with_all(BusinessUnit, :name)
		lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		lost_reasons = lost_reasons-[57,49]
		lost_reasons = lost_reasons+[nil]
		online_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%Online%").pluck(:id).uniq
		online_source_category_ids += [868]
		facebook_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%FACEBOOK%").pluck(:id).uniq
		google_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%Google%").pluck(:id).uniq
		google_source_category_ids += [868]
		if params[:project] == nil
			@project_selected = 2
			leads_generated_hash = {}
			qualified_leads_hash = {}
			qualified_percentage_hash = {}
			leads_generated_hash[:name] = 'Enquiries'
			qualified_leads_hash[:name] = 'Qualified Leads'
			qualified_percentage_hash[:name] = 'Qualified Percentages'
			leads_generated_data = []
			qualified_leads_data = []
			qualified_percentage_data = []

			online_leads_generated_hash = {}
			online_qualified_leads_hash = {}
			online_qualified_percentage_hash = {}
			online_leads_generated_hash[:name] = 'Enquiries'
			online_qualified_leads_hash[:name] = 'Qualified Leads'
			online_qualified_percentage_hash[:name] = 'Qualified Percentages'
			online_leads_generated_data = []
			online_qualified_leads_data = []
			online_qualified_percentage_data = []

			facebook_leads_generated_hash = {}
			facebook_qualified_leads_hash = {}
			facebook_qualified_percentage_hash = {}
			facebook_leads_generated_hash[:name] = 'Enquiries'
			facebook_qualified_leads_hash[:name] = 'Qualified Leads'
			facebook_qualified_percentage_hash[:name] = 'Qualified Percentages'
			facebook_leads_generated_data = []
			facebook_qualified_leads_data = []
			facebook_qualified_percentage_data = []

			google_leads_generated_hash = {}
			google_qualified_leads_hash = {}
			google_qualified_percentage_hash = {}
			google_leads_generated_hash[:name] = 'Enquiries'
			google_qualified_leads_hash[:name] = 'Qualified Leads'
			google_qualified_percentage_hash[:name] = 'Qualified Percentages'
			google_leads_generated_data = []
			google_qualified_leads_data = []
			google_qualified_percentage_data = []
			
			@weeks = []
			count = 13
			current_week = DateTime.now.beginning_of_week
			count.times do |counter|
				@weeks += [(current_week.beginning_of_day.end_of_week-counter.weeks).strftime('%d/%m/%y')]
				weekstart = current_week.beginning_of_day-counter.weeks
				weekend = current_week.beginning_of_day.end_of_week-counter.weeks
				lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				leads_generated_data += [lead_count]
				qualified_leads_count = Lead.where(business_unit_id: @project_selected).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				qualified_leads_data += [qualified_leads_count]
				qualified_percentage_data += [((qualified_leads_count.to_f/lead_count.to_f)*100).round(2)]

				online_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				online_leads_generated_data += [online_lead_count]
				online_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: online_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				online_qualified_leads_data += [online_qualified_leads_count]
				online_qualified_percentage_data += [((online_qualified_leads_count.to_f/online_lead_count.to_f)*100).round(2)]

				facebook_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				facebook_leads_generated_data += [facebook_lead_count]
				facebook_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: facebook_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				facebook_qualified_leads_data += [facebook_qualified_leads_count]
				facebook_qualified_percentage_data += [((facebook_qualified_leads_count.to_f/facebook_lead_count.to_f)*100).round(2)]

				google_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				google_leads_generated_data += [google_lead_count]
				google_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: google_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
				google_qualified_leads_data += [google_qualified_leads_count]
				google_qualified_percentage_data += [((google_qualified_leads_count.to_f/google_lead_count.to_f)*100).round(2)]
			end
			leads_generated_hash[:data] = leads_generated_data.reverse
			qualified_leads_hash[:data] = qualified_leads_data.reverse
			qualified_percentage_hash[:data] = qualified_percentage_data.reverse

			online_leads_generated_hash[:data] = online_leads_generated_data.reverse
			online_qualified_leads_hash[:data] = online_qualified_leads_data.reverse
			online_qualified_percentage_hash[:data] = online_qualified_percentage_data.reverse

			facebook_leads_generated_hash[:data] = facebook_leads_generated_data.reverse
			facebook_qualified_leads_hash[:data] = facebook_qualified_leads_data.reverse
			facebook_qualified_percentage_hash[:data] = facebook_qualified_percentage_data.reverse

			google_leads_generated_hash[:data] = google_leads_generated_data.reverse
			google_qualified_leads_hash[:data] = google_qualified_leads_data.reverse
			google_qualified_percentage_hash[:data] = google_qualified_percentage_data.reverse
			@series_1 = [leads_generated_hash, qualified_leads_hash].to_json.html_safe
			@series_2 = [qualified_leads_hash, qualified_percentage_hash].to_json.html_safe

			@online_series_1 = [online_leads_generated_hash, online_qualified_leads_hash].to_json.html_safe
			@online_series_2 = [online_qualified_leads_hash, online_qualified_percentage_hash].to_json.html_safe

			@facebook_series_1 = [facebook_leads_generated_hash, facebook_qualified_leads_hash].to_json.html_safe
			@facebook_series_2 = [facebook_qualified_leads_hash, facebook_qualified_percentage_hash].to_json.html_safe

			@google_series_1 = [google_leads_generated_hash, google_qualified_leads_hash].to_json.html_safe
			@google_series_2 = [google_qualified_leads_hash, google_qualified_percentage_hash].to_json.html_safe
			@weeks = @weeks.reverse.to_json.html_safe
		else
			@project_selected = params[:project][:selected].to_i
			leads_generated_hash = {}
			qualified_leads_hash = {}
			qualified_percentage_hash = {}
			leads_generated_hash[:name] = 'Enquiries'
			qualified_leads_hash[:name] = 'Qualified Leads'
			qualified_percentage_hash[:name] = 'Qualified Percentages'
			leads_generated_data = []
			qualified_leads_data = []
			qualified_percentage_data = []

			online_leads_generated_hash = {}
			online_qualified_leads_hash = {}
			online_qualified_percentage_hash = {}
			online_leads_generated_hash[:name] = 'Enquiries'
			online_qualified_leads_hash[:name] = 'Qualified Leads'
			online_qualified_percentage_hash[:name] = 'Qualified Percentages'
			online_leads_generated_data = []
			online_qualified_leads_data = []
			online_qualified_percentage_data = []

			facebook_leads_generated_hash = {}
			facebook_qualified_leads_hash = {}
			facebook_qualified_percentage_hash = {}
			facebook_leads_generated_hash[:name] = 'Enquiries'
			facebook_qualified_leads_hash[:name] = 'Qualified Leads'
			facebook_qualified_percentage_hash[:name] = 'Qualified Percentages'
			facebook_leads_generated_data = []
			facebook_qualified_leads_data = []
			facebook_qualified_percentage_data = []

			google_leads_generated_hash = {}
			google_qualified_leads_hash = {}
			google_qualified_percentage_hash = {}
			google_leads_generated_hash[:name] = 'Enquiries'
			google_qualified_leads_hash[:name] = 'Qualified Leads'
			google_qualified_percentage_hash[:name] = 'Qualified Percentages'
			google_leads_generated_data = []
			google_qualified_leads_data = []
			google_qualified_percentage_data = []

			@weeks = []
			count = 13
			current_week = DateTime.now.beginning_of_week
			count.times do |counter|
				if @project_selected == -1 || @project_selected == "-1"
					@weeks += [(current_week.beginning_of_day.end_of_week-counter.weeks).strftime('%d/%m/%y')]
					weekstart = current_week.beginning_of_day-counter.weeks
					weekend = current_week.beginning_of_day.end_of_week-counter.weeks
					lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					leads_generated_data += [lead_count]
					qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					qualified_leads_data += [qualified_leads_count]
					qualified_percentage_data += [((qualified_leads_count.to_f/lead_count.to_f)*100).round(2)]

					online_lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					online_leads_generated_data += [online_lead_count]
					online_qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: online_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					online_qualified_leads_data += [online_qualified_leads_count]
					online_qualified_percentage_data += [((online_qualified_leads_count.to_f/online_lead_count.to_f)*100).round(2)]

					facebook_lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					facebook_leads_generated_data += [facebook_lead_count]
					facebook_qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: facebook_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					facebook_qualified_leads_data += [facebook_qualified_leads_count]
					facebook_qualified_percentage_data += [((facebook_qualified_leads_count.to_f/facebook_lead_count.to_f)*100).round(2)]

					google_lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					google_leads_generated_data += [google_lead_count]
					google_qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: google_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					google_qualified_leads_data += [google_qualified_leads_count]
					google_qualified_percentage_data += [((google_qualified_leads_count.to_f/google_lead_count.to_f)*100).round(2)]
				else
					@weeks += [(current_week.beginning_of_day.end_of_week-counter.weeks).strftime('%d/%m/%y')]
					weekstart = current_week.beginning_of_day-counter.weeks
					weekend = current_week.beginning_of_day.end_of_week-counter.weeks
					lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					leads_generated_data += [lead_count]
					qualified_leads_count = Lead.where(business_unit_id: @project_selected).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					qualified_leads_data += [qualified_leads_count]
					qualified_percentage_data += [((qualified_leads_count.to_f/lead_count.to_f)*100).round(2)]

					online_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					online_leads_generated_data += [online_lead_count]
					online_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: online_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					online_qualified_leads_data += [online_qualified_leads_count]
					online_qualified_percentage_data += [((online_qualified_leads_count.to_f/online_lead_count.to_f)*100).round(2)]

					facebook_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					facebook_leads_generated_data += [facebook_lead_count]
					facebook_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: facebook_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					facebook_qualified_leads_data += [facebook_qualified_leads_count]
					facebook_qualified_percentage_data += [((facebook_qualified_leads_count.to_f/facebook_lead_count.to_f)*100).round(2)]

					google_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					google_leads_generated_data += [google_lead_count]
					google_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: google_source_category_ids).where.not(qualified_on: nil).where("leads.generated_on >= ? AND leads.generated_on < ?", weekstart.to_datetime, weekend.to_datetime+1.day).count
					google_qualified_leads_data += [google_qualified_leads_count]
					google_qualified_percentage_data += [((google_qualified_leads_count.to_f/google_lead_count.to_f)*100).round(2)]
				end
			end
			leads_generated_hash[:data] = leads_generated_data.reverse
			qualified_leads_hash[:data] = qualified_leads_data.reverse
			qualified_percentage_hash[:data] = qualified_percentage_data.reverse

			online_leads_generated_hash[:data] = online_leads_generated_data.reverse
			online_qualified_leads_hash[:data] = online_qualified_leads_data.reverse
			online_qualified_percentage_hash[:data] = online_qualified_percentage_data.reverse

			facebook_leads_generated_hash[:data] = facebook_leads_generated_data.reverse
			facebook_qualified_leads_hash[:data] = facebook_qualified_leads_data.reverse
			facebook_qualified_percentage_hash[:data] = facebook_qualified_percentage_data.reverse

			google_leads_generated_hash[:data] = google_leads_generated_data.reverse
			google_qualified_leads_hash[:data] = google_qualified_leads_data.reverse
			google_qualified_percentage_hash[:data] = google_qualified_percentage_data.reverse
			@series_1 = [leads_generated_hash, qualified_leads_hash].to_json.html_safe
			@series_2 = [qualified_leads_hash, qualified_percentage_hash].to_json.html_safe

			@online_series_1 = [online_leads_generated_hash, online_qualified_leads_hash].to_json.html_safe
			@online_series_2 = [online_qualified_leads_hash, online_qualified_percentage_hash].to_json.html_safe

			@facebook_series_1 = [facebook_leads_generated_hash, facebook_qualified_leads_hash].to_json.html_safe
			@facebook_series_2 = [facebook_qualified_leads_hash, facebook_qualified_percentage_hash].to_json.html_safe

			@google_series_1 = [google_leads_generated_hash, google_qualified_leads_hash].to_json.html_safe
			@google_series_2 = [google_qualified_leads_hash, google_qualified_percentage_hash].to_json.html_safe
			@weeks = @weeks.reverse.to_json.html_safe
		end
	else
		@sources = SourceCategory.where(organisation_id: current_personnel.organisation_id)
		@projects = selections_with_all(BusinessUnit, :name)
		if params[:project]==nil
			@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			if params[:project][:selected]=='-1'
			@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
			@project_selected=params[:project][:selected]
			end
		end
		
		@site_executives=selections_with_all_active(Personnel, :name)
		if params[:site_executive]==nil
		@executive=-1
		elsif params[:site_executive][:picked]==-1
		@executive=-1
		else
		@executive=params[:site_executive][:picked].to_i	
		end	
	end
end

def weekly_source_wise_leads_with_opening
	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:project]==nil
	@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	else
		if params[:project][:selected]=='-1'
		@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
		@project_selected=params[:project][:selected]
		end
	end
	
	@site_executives=selections_with_all_active(Personnel, :name)
	if params[:site_executive]==nil
	@executive=-1
	elsif params[:site_executive][:picked]==-1
	@executive=-1
	else
	@executive=params[:site_executive][:picked].to_i	
	end				
end

def monthly_source_wise_leads
	if current_personnel.business_unit.organisation_id == 1
		@projects = selections_with_all(BusinessUnit, :name)
		lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		lost_reasons = lost_reasons-[57,49]
		lost_reasons = lost_reasons+[nil]
		online_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%Online%").pluck(:id).uniq
		online_source_category_ids += [868]
		facebook_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%FACEBOOK%").pluck(:id).uniq
		google_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%Google%").pluck(:id).uniq
		google_source_category_ids += [868]

		leads_generated_hash = {}
		qualified_leads_hash = {}
		site_visited_hash = {}
		leads_generated_hash[:name] = 'Enquiries'
		qualified_leads_hash[:name] = 'Qualified Leads'
		site_visited_hash[:name] = 'Site visited'
		leads_generated_data = []
		qualified_leads_data = []
		site_visited_data = []

		online_leads_generated_hash = {}
		online_qualified_leads_hash = {}
		online_site_visited_hash = {}
		online_leads_generated_hash[:name] = 'Enquiries'
		online_qualified_leads_hash[:name] = 'Qualified Leads'
		online_site_visited_hash[:name] = 'Site visited'
		online_leads_generated_data = []
		online_qualified_leads_data = []
		online_site_visited_data = []

		facebook_leads_generated_hash = {}
		facebook_qualified_leads_hash = {}
		facebook_site_visited_hash = {}
		facebook_leads_generated_hash[:name] = 'Enquiries'
		facebook_qualified_leads_hash[:name] = 'Qualified Leads'
		facebook_site_visited_hash[:name] = 'Site visited'
		facebook_leads_generated_data = []
		facebook_qualified_leads_data = []
		facebook_site_visited_data = []

		google_leads_generated_hash = {}
		google_qualified_leads_hash = {}
		google_site_visited_hash = {}
		google_leads_generated_hash[:name] = 'Enquiries'
		google_qualified_leads_hash[:name] = 'Qualified Leads'
		google_site_visited_hash[:name] = 'Site visited'
		google_leads_generated_data = []
		google_qualified_leads_data = []
		google_site_visited_data = []

		@months = []
		@online_months = []
		@facebook_months = []
		@google_months = []
		
		if params[:project] == nil
			@project_selected = 2
			leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
			online_leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
			facebook_leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
			google_leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
		else	
	        @project_selected = params[:project][:selected].to_i
			if @project_selected == -1 || @project_selected == "-1"
				leads_generated_raw = Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
				online_leads_generated_raw = Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
				facebook_leads_generated_raw = Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
				google_leads_generated_raw = Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
			else
				leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
				online_leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
				facebook_leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
				google_leads_generated_raw = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where('leads.generated_on >= ? AND leads.generated_on < ?', DateTime.now.beginning_of_month-12.month, DateTime.now.end_of_month+1.day).sort_by{|lead| lead.created_at}.group_by{|x| [x.generated_on.to_date.year, x.generated_on.to_date.month]}
			end
		end
        leads_generated_raw.each do |key, value|
          @months += [Date::MONTHNAMES[key[1]]]
          leads_generated_data += [value.count]
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end  
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end  
          end
          qualified_leads_data += [qualify_count]
		  site_visited_data += [sv_count]
        end
        online_leads_generated_raw.each do |key, value|
          @online_months += [Date::MONTHNAMES[key[1]]]
          online_leads_generated_data += [value.count]
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end  
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end  
          end
          online_qualified_leads_data += [qualify_count]
		  online_site_visited_data += [sv_count]
        end
        facebook_leads_generated_raw.each do |key, value|
          @facebook_months += [Date::MONTHNAMES[key[1]]]
          facebook_leads_generated_data += [value.count]
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end  
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end  
          end
          facebook_qualified_leads_data += [qualify_count]
		  facebook_site_visited_data += [sv_count]
        end
        google_leads_generated_raw.each do |key, value|
          @google_months += [Date::MONTHNAMES[key[1]]]
          google_leads_generated_data += [value.count]
          qualify_count = 0
          sv_count = 0
          value.each do |lead|
            if lead.qualified_on == nil
            else
                qualify_count += 1
            end  
            if lead.site_visited_on == nil
            else
                sv_count += 1
            end  
          end
          google_qualified_leads_data += [qualify_count]
		  google_site_visited_data += [sv_count]
        end
        leads_generated_hash[:data] = leads_generated_data
        qualified_leads_hash[:data] = qualified_leads_data
        site_visited_hash[:data] = site_visited_data

        online_leads_generated_hash[:data] = online_leads_generated_data
		online_qualified_leads_hash[:data] = online_qualified_leads_data
		online_site_visited_hash[:data] = online_site_visited_data

		facebook_leads_generated_hash[:data] = facebook_leads_generated_data
		facebook_qualified_leads_hash[:data] = facebook_qualified_leads_data
		facebook_site_visited_hash[:data] = facebook_site_visited_data

		google_leads_generated_hash[:data] = google_leads_generated_data
		google_qualified_leads_hash[:data] = google_qualified_leads_data
		google_site_visited_hash[:data] = google_site_visited_data
        @series = [leads_generated_hash, qualified_leads_hash, site_visited_hash].to_json.html_safe
        @online_series = [online_leads_generated_hash, online_qualified_leads_hash, online_site_visited_hash].to_json.html_safe
		@facebook_series = [facebook_leads_generated_hash, facebook_qualified_leads_hash, facebook_site_visited_hash].to_json.html_safe
		@google_series = [google_leads_generated_hash, google_qualified_leads_hash, google_site_visited_hash].to_json.html_safe
		@months = @months.to_json.html_safe
        @online_months = @online_months.to_json.html_safe
        @facebook_months = @facebook_months.to_json.html_safe
        @google_months = @google_months.to_json.html_safe
	else
		@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
		@projects=selections_with_all(BusinessUnit, :name)
		if params[:project]==nil
		@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			if params[:project][:selected]=='-1'
			@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
			@project_selected=params[:project][:selected]
			end
		end
		
		@site_executives=selections_with_all_active(Personnel, :name)
		if params[:site_executive]==nil
		@executive=-1
		elsif params[:site_executive][:picked]==-1
		@executive=-1
		else
		@executive=params[:site_executive][:picked].to_i	
		end	
	end
end

def monthly_chart_last_year
	@projects = selections_with_all(BusinessUnit, :name)
	lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	lost_reasons = lost_reasons-[57,49]
	lost_reasons = lost_reasons+[nil]
	online_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%Online%").pluck(:id).uniq
	online_source_category_ids += [868]
	facebook_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%FACEBOOK%").pluck(:id).uniq
	google_source_category_ids = SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%Google%").pluck(:id).uniq
	google_source_category_ids += [868]
	if params[:project] == nil
		@project_selected = 2
		leads_generated_hash = {}
		qualified_leads_hash = {}
		site_visited_hash = {}
		leads_generated_hash[:name] = 'Enquiries'
		qualified_leads_hash[:name] = 'Qualified Leads'
		site_visited_hash[:name] = 'Site visited'
		leads_generated_data = []
		qualified_leads_data = []
		site_visited_data = []

		online_leads_generated_hash = {}
		online_qualified_leads_hash = {}
		online_site_visited_hash = {}
		online_leads_generated_hash[:name] = 'Enquiries'
		online_qualified_leads_hash[:name] = 'Qualified Leads'
		online_site_visited_hash[:name] = 'Site visited'
		online_leads_generated_data = []
		online_qualified_leads_data = []
		online_site_visited_data = []

		facebook_leads_generated_hash = {}
		facebook_qualified_leads_hash = {}
		facebook_site_visited_hash = {}
		facebook_leads_generated_hash[:name] = 'Enquiries'
		facebook_qualified_leads_hash[:name] = 'Qualified Leads'
		facebook_site_visited_hash[:name] = 'Site visited'
		facebook_leads_generated_data = []
		facebook_qualified_leads_data = []
		facebook_site_visited_data = []

		google_leads_generated_hash = {}
		google_qualified_leads_hash = {}
		google_site_visited_hash = {}
		google_leads_generated_hash[:name] = 'Enquiries'
		google_qualified_leads_hash[:name] = 'Qualified Leads'
		google_site_visited_hash[:name] = 'Site visited'
		google_leads_generated_data = []
		google_qualified_leads_data = []
		google_site_visited_data = []

		
		@months = []
		count = 12
		12.times do |counter|
			@months += [Date::MONTHNAMES[((Time.now-1.year-1.month) - counter.months).month]]
			year = ((Time.now-1.year)-(counter.months)).year
			month = ((Time.now-1.year-1.month)-(counter.months)).month
			lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
			leads_generated_data += [lead_count]
			qualified_leads_count = Lead.where(business_unit_id: @project_selected).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			qualified_leads_data += [qualified_leads_count]
			sv_leads_count = Lead.where(business_unit_id: @project_selected).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			site_visited_data += [sv_leads_count]

			online_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
			online_leads_generated_data += [online_lead_count]
			online_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: online_source_category_ids).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			online_qualified_leads_data += [online_qualified_leads_count]
			online_sv_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: online_source_category_ids).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			online_site_visited_data += [online_sv_leads_count]

			facebook_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
			facebook_leads_generated_data += [facebook_lead_count]
			facebook_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: facebook_source_category_ids).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			facebook_qualified_leads_data += [facebook_qualified_leads_count]
			facebook_sv_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: facebook_source_category_ids).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			facebook_site_visited_data += [facebook_sv_leads_count]

			google_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
			google_leads_generated_data += [google_lead_count]
			google_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: google_source_category_ids).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			google_qualified_leads_data += [google_qualified_leads_count]
			google_sv_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: google_source_category_ids).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
			google_site_visited_data += [google_sv_leads_count]
		end
		leads_generated_hash[:data] = leads_generated_data.reverse
		qualified_leads_hash[:data] = qualified_leads_data.reverse
		site_visited_hash[:data] = site_visited_data.reverse

		online_leads_generated_hash[:data] = online_leads_generated_data.reverse
		online_qualified_leads_hash[:data] = online_qualified_leads_data.reverse
		online_site_visited_hash[:data] = online_site_visited_data.reverse

		facebook_leads_generated_hash[:data] = facebook_leads_generated_data.reverse
		facebook_qualified_leads_hash[:data] = facebook_qualified_leads_data.reverse
		facebook_site_visited_hash[:data] = facebook_site_visited_data.reverse

		google_leads_generated_hash[:data] = google_leads_generated_data.reverse
		google_qualified_leads_hash[:data] = google_qualified_leads_data.reverse
		google_site_visited_hash[:data] = google_site_visited_data.reverse

		@series = [leads_generated_hash, qualified_leads_hash, site_visited_hash].to_json.html_safe
		@online_series = [online_leads_generated_hash, online_qualified_leads_hash, online_site_visited_hash].to_json.html_safe
		@facebook_series = [facebook_leads_generated_hash, facebook_qualified_leads_hash, facebook_site_visited_hash].to_json.html_safe
		@google_series = [google_leads_generated_hash, google_qualified_leads_hash, google_site_visited_hash].to_json.html_safe
		@months = @months.reverse.to_json.html_safe
	else
		@project_selected = params[:project][:selected].to_i
		leads_generated_hash = {}
		qualified_leads_hash = {}
		site_visited_hash = {}
		leads_generated_hash[:name] = 'Enquiries'
		qualified_leads_hash[:name] = 'Qualified Leads'
		site_visited_hash[:name] = 'Site visited'
		leads_generated_data = []
		qualified_leads_data = []
		site_visited_data = []

		online_leads_generated_hash = {}
		online_qualified_leads_hash = {}
		online_site_visited_hash = {}
		online_leads_generated_hash[:name] = 'Enquiries'
		online_qualified_leads_hash[:name] = 'Qualified Leads'
		online_site_visited_hash[:name] = 'Site visited'
		online_leads_generated_data = []
		online_qualified_leads_data = []
		online_site_visited_data = []

		facebook_leads_generated_hash = {}
		facebook_qualified_leads_hash = {}
		facebook_site_visited_hash = {}
		facebook_leads_generated_hash[:name] = 'Enquiries'
		facebook_qualified_leads_hash[:name] = 'Qualified Leads'
		facebook_site_visited_hash[:name] = 'Site visited'
		facebook_leads_generated_data = []
		facebook_qualified_leads_data = []
		facebook_site_visited_data = []

		google_leads_generated_hash = {}
		google_qualified_leads_hash = {}
		google_site_visited_hash = {}
		google_leads_generated_hash[:name] = 'Enquiries'
		google_qualified_leads_hash[:name] = 'Qualified Leads'
		google_site_visited_hash[:name] = 'Site visited'
		google_leads_generated_data = []
		google_qualified_leads_data = []
		google_site_visited_data = []
		
		@months = []
		count = 12

		12.times do |counter|
			if @project_selected == -1 || @project_selected == "-1"
				@months += [Date::MONTHNAMES[((Time.now-1.year-1.month) - counter.months).month]]
				year = ((Time.now-1.year)-(counter.months)).year
				month = ((Time.now-1.year-1.month)-(counter.months)).month
				lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				leads_generated_data += [lead_count]
				qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where.not(qualified_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				qualified_leads_data += [qualified_leads_count]
				sv_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where.not(site_visited_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				site_visited_data += [sv_leads_count]

				online_lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				online_leads_generated_data += [online_lead_count]
				online_qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: online_source_category_ids).where.not(qualified_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				online_qualified_leads_data += [online_qualified_leads_count]
				online_sv_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: online_source_category_ids).where.not(site_visited_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				online_site_visited_data += [online_sv_leads_count]

				facebook_lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				facebook_leads_generated_data += [facebook_lead_count]
				facebook_qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: facebook_source_category_ids).where.not(qualified_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				facebook_qualified_leads_data += [facebook_qualified_leads_count]
				facebook_sv_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: facebook_source_category_ids).where.not(site_visited_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				facebook_site_visited_data += [facebook_sv_leads_count]

				google_lead_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				google_leads_generated_data += [google_lead_count]
				google_qualified_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: google_source_category_ids).where.not(qualified_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				google_qualified_leads_data += [google_qualified_leads_count]
				google_sv_leads_count = Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, source_category_id: google_source_category_ids).where.not(site_visited_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
				google_site_visited_data += [google_sv_leads_count]
			else
				@months += [Date::MONTHNAMES[((Time.now-1.year-1.month) - counter.months).month]]
				year = ((Time.now-1.year)-(counter.months)).year
				month = ((Time.now-1.year-1.month)-(counter.months)).month
				lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
				leads_generated_data += [lead_count]
				qualified_leads_count = Lead.where(business_unit_id: @project_selected).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				qualified_leads_data += [qualified_leads_count]
				sv_leads_count = Lead.where(business_unit_id: @project_selected).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				site_visited_data += [sv_leads_count]

				online_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: online_source_category_ids).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
				online_leads_generated_data += [online_lead_count]
				online_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: online_source_category_ids).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				online_qualified_leads_data += [online_qualified_leads_count]
				online_sv_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: online_source_category_ids).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				online_site_visited_data += [online_sv_leads_count]

				facebook_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: facebook_source_category_ids).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
				facebook_leads_generated_data += [facebook_lead_count]
				facebook_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: facebook_source_category_ids).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				facebook_qualified_leads_data += [facebook_qualified_leads_count]
				facebook_sv_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: facebook_source_category_ids).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				facebook_site_visited_data += [facebook_sv_leads_count]

				google_lead_count = Lead.where(business_unit_id: @project_selected, lost_reason_id: lost_reasons, source_category_id: google_source_category_ids).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
				google_leads_generated_data += [google_lead_count]
				google_qualified_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: google_source_category_ids).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				google_qualified_leads_data += [google_qualified_leads_count]
				google_sv_leads_count = Lead.where(business_unit_id: @project_selected, source_category_id: google_source_category_ids).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
				google_site_visited_data += [google_sv_leads_count]
			end
		end
		leads_generated_hash[:data] = leads_generated_data.reverse
		qualified_leads_hash[:data] = qualified_leads_data.reverse
		site_visited_hash[:data] = site_visited_data.reverse
		online_leads_generated_hash[:data] = online_leads_generated_data.reverse
		online_qualified_leads_hash[:data] = online_qualified_leads_data.reverse
		online_site_visited_hash[:data] = online_site_visited_data.reverse

		facebook_leads_generated_hash[:data] = facebook_leads_generated_data.reverse
		facebook_qualified_leads_hash[:data] = facebook_qualified_leads_data.reverse
		facebook_site_visited_hash[:data] = facebook_site_visited_data.reverse

		google_leads_generated_hash[:data] = google_leads_generated_data.reverse
		google_qualified_leads_hash[:data] = google_qualified_leads_data.reverse
		google_site_visited_hash[:data] = google_site_visited_data.reverse

		@series = [leads_generated_hash, qualified_leads_hash, site_visited_hash].to_json.html_safe
		@online_series = [online_leads_generated_hash, online_qualified_leads_hash, online_site_visited_hash].to_json.html_safe
		@facebook_series = [facebook_leads_generated_hash, facebook_qualified_leads_hash, facebook_site_visited_hash].to_json.html_safe
		@google_series = [google_leads_generated_hash, google_qualified_leads_hash, google_site_visited_hash].to_json.html_safe
		@months = @months.reverse.to_json.html_safe
	end
end


def monthly_source_wise_leads_with_opening
	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:project]==nil
	@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	else
		if params[:project][:selected]=='-1'
		@project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
		@project_selected=params[:project][:selected]
		end
	end
	
	@site_executives=selections_with_all_active(Personnel, :name)
	if params[:site_executive]==nil
	@executive=-1
	elsif params[:site_executive][:picked]==-1
	@executive=-1
	else
	@executive=params[:site_executive][:picked].to_i	
	end				
end

def personnel_wise_leads
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:project]==nil
	project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	else
		if params[:project][:selected]=='-1'
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
		project_selected=params[:project][:selected]
		end
	end

	designated_personnel=[]
	personnels_array=Personnel.where(organisation_id: current_personnel.organisation_id)
	personnels_array.each do |person|
		if person.status=='Sales Executive' || person.status=='Back Office' || current_personnel.status=='Marketing'  
			designated_personnel+=[person.id]
		end
	end
	
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
		@total_leads=Lead.where(personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil).group("personnel_id").count
		@fresh_leads=Lead.includes(:follow_ups).where(:follow_ups => {lead_id: nil}, :leads => { :status => nil }, personnel_id: designated_personnel, business_unit: project_selected).group("leads.personnel_id").count
		@qualified_leads=Lead.where(personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil, site_visited_on: nil).where('qualified_on is not ?', nil).group("personnel_id").count
		@isv_leads=Lead.where(personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil).where('interested_in_site_visit_on is not ?', nil).group("personnel_id").count
		@follow_ups_due_records=Lead.includes(:follow_ups).where(:follow_ups => {last: true}, personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil).where('follow_ups.follow_up_time <= ?', Date.today+1.day).group("leads.personnel_id")
		@follow_ups_due=@follow_ups_due_records.count
		@follow_ups_due_site_visited=@follow_ups_due_records.where.not(site_visited_on: nil).count
		@follow_ups_due_field_visited=@follow_ups_due_records.where(osv: false, status: false).count
		@follow_ups_due_visit_organised=@follow_ups_due_records.where(osv: true).count
		@future_follow_ups_records=Lead.includes(:follow_ups).where(:follow_ups => {last: true}, personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil).where('follow_ups.follow_up_time > ?', Date.today+1.day).group("leads.personnel_id")
		@future_follow_ups=@future_follow_ups_records.count
		@future_follow_ups_site_visited=@future_follow_ups_records.where.not(site_visited_on: nil).count
		@future_follow_ups_field_visited=@future_follow_ups_records.where(osv: false, status: false).count
		@future_follow_ups_visit_organised=@future_follow_ups_records.where(osv: true).count
	elsif current_personnel.status=='Team Lead'
		team_members=current_personnel.member_array	
		@total_leads=Lead.where(business_unit: project_selected, booked_on: nil, :leads => {personnel_id: team_members} ).group("leads.personnel_id").count
		@fresh_leads=Lead.includes(:follow_ups).where(:follow_ups => {lead_id: nil}, :leads => { :status => nil }, business_unit: project_selected, :leads => {personnel_id: team_members}).group("leads.personnel_id").count
		@qualified_leads=Lead.where(business_unit: project_selected, personnel_id: team_members, booked_on: nil, site_visited_on: nil).where('qualified_on is not ?', nil).group("personnel_id").count
		@isv_leads=Lead.where(business_unit: project_selected, personnel_id: team_members, booked_on: nil).where('interested_in_site_visit_on is not ?', nil).group("personnel_id").count
		@follow_ups_due_records=Lead.includes(:personnel, :follow_ups).where(:follow_ups => {last: true}, business_unit: project_selected, booked_on: nil, :leads => {personnel_id: team_members}).where('follow_ups.follow_up_time <= ?', Date.today+1.day).group("leads.personnel_id")
		@follow_ups_due=@follow_ups_due_records.count
		@follow_ups_due_site_visited=@follow_ups_due_records.where.not(site_visited_on: nil).count
		@follow_ups_due_field_visited=@follow_ups_due_records.where(osv: false, status: false).count
		@follow_ups_due_visit_organised=@follow_ups_due_records.where(osv: true).count
		@future_follow_ups_records=Lead.includes(:personnel, :follow_ups).where(:follow_ups => {last: true}, personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil, :leads => {personnel_id: team_members}).where('follow_ups.follow_up_time > ?', Date.today+1.day).group("leads.personnel_id")
		@future_follow_ups=@future_follow_ups_records.count
		@future_follow_ups_site_visited=@future_follow_ups_records.where.not(site_visited_on: nil).count
		@future_follow_ups_field_visited=@future_follow_ups_records.where(osv: false, status: false).count
		@future_follow_ups_visit_organised=@future_follow_ups_records.where(osv: true).count
	else
		@total_leads=Lead.where(personnel_id: current_personnel.id, business_unit: project_selected, booked_on: nil, :leads => {personnel_id: current_personnel.id}).group("leads.personnel_id").count
		@fresh_leads=Lead.includes(:follow_ups).where(:follow_ups => {lead_id: nil}, :leads => { :status => nil, personnel_id: current_personnel.id}, business_unit: project_selected).group("leads.personnel_id").count
		@qualified_leads=Lead.where(personnel_id: current_personnel.id, business_unit: project_selected, booked_on: nil, site_visited_on: nil).where('leads.qualified_on is not ?', nil).group("personnel_id").count
		@isv_leads=Lead.where(personnel_id: current_personnel.id, business_unit: project_selected, booked_on: nil).where('leads.interested_in_site_visit_on is not ?', nil).group("personnel_id").count
		@follow_ups_due_records=Lead.includes(:follow_ups).where(:follow_ups => {last: true}, business_unit: project_selected, booked_on: nil, :leads => {personnel_id: current_personnel.id}).where('follow_ups.follow_up_time <= ?', Date.today+1.day).group("leads.personnel_id")
		@follow_ups_due=@follow_ups_due_records.count
		@follow_ups_due_site_visited=@follow_ups_due_records.where.not(site_visited_on: nil).count
		@follow_ups_due_field_visited=@follow_ups_due_records.where(osv: false, status: false).count
		@follow_ups_due_visit_organised=@follow_ups_due_records.where(osv: true).count
		@future_follow_ups_records=Lead.includes(:follow_ups).where(:follow_ups => {last: true}, business_unit: project_selected, booked_on: nil, :leads => {personnel_id: current_personnel.id}).where('follow_ups.follow_up_time > ?', Date.today+1.day).group("leads.personnel_id")
		@future_follow_ups=@future_follow_ups_records.count
		@future_follow_ups_site_visited=@future_follow_ups_records.where.not(site_visited_on: nil).count
		@future_follow_ups_field_visited=@future_follow_ups_records.where(osv: false, status: false).count
		@future_follow_ups_visit_organised=@future_follow_ups_records.where(osv: true).count		
	end
end

def personnel_wise_leads_genie
	designated_personnel=[]
	project_selected=BusinessUnit.where(organisation_id: 1).pluck(:id)
	
	personnels_array=Personnel.where(organisation_id: 1)
	personnels_array.each do |person|
		if person.status=='Sales Executive' || person.status=='Back Office'
			designated_personnel+=[person.id]
		end
	end
	
	@total_leads=Lead.includes(:personnel).where(:personnels => {id: designated_personnel}, business_unit: project_selected, booked_on: nil).group("personnels.name").count
	@fresh_leads=Lead.includes(:follow_ups, :personnel).where(:follow_ups => {lead_id: nil}, :leads => { :status => nil }, personnel_id: designated_personnel, business_unit: project_selected).group("personnels.name").count
	@follow_ups_due_records=Lead.includes(:follow_ups, :personnel).where(:follow_ups => {last: true}, personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil).where('follow_ups.follow_up_time <= ?', Date.today+1.day).group("personnels.name")
	@follow_ups_due=@follow_ups_due_records.count
	@follow_ups_due_site_visited=@follow_ups_due_records.where.not(site_visited_on: nil).count
	@follow_ups_due_field_visited=@follow_ups_due_records.where(osv: false, status: false).count
	@follow_ups_due_visit_organised=@follow_ups_due_records.where(osv: true).count
	@future_follow_ups_records=Lead.includes(:follow_ups, :personnel).where(:follow_ups => {last: true}, personnel_id: designated_personnel, business_unit: project_selected, booked_on: nil).where('follow_ups.follow_up_time > ?', Date.today+1.day).group("personnels.name")
	@future_follow_ups=@future_follow_ups_records.count
	@future_follow_ups_site_visited=@future_follow_ups_records.where.not(site_visited_on: nil).count
	@future_follow_ups_field_visited=@future_follow_ups_records.where(osv: false, status: false).count
	@future_follow_ups_visit_organised=@future_follow_ups_records.where(osv: true).count
	

end

def lost_reason_wise_leads
	@source_categories=selections(SourceCategory.where(inactive: [nil,false]), :heirarchy)
	@source_categories=[['All Categories',-1]]+@source_categories
	@source_category_selected=-1
	if params[:date]==nil
		@from = DateTime.now.beginning_of_month
		@to = DateTime.now.end_of_month
	else	
		@from = params[:date][:from]
		@to = params[:date][:to]
		@month = @from.to_date.month
		year = @from.to_date.year
	end
	@site_visited_lead = params[:site_visited]
	@without_testing_and_duplicate = params[:without_test_duplicate]
	# @year = year
	if params[:lost] == nil
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads = Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads = Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		elsif current_personnel.status=='Team Lead'
			team_members = current_personnel.member_array	
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads = Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads = Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		else
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		end
	elsif params[:lost][:source_category_id].to_i ==-1
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads = Lead.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads = Lead.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		elsif current_personnel.status=='Team Lead'
			team_members = current_personnel.member_array	
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: team_members}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		else
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {id: current_personnel.id}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		end
	else
		@source_category_selected=params[:lost][:source_category_id].to_i
		if current_personnel.name=='Riddhi Gadhiya'
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: current_personnel.business_unit_id}).where.not(lost_reason_id: nil).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: current_personnel.business_unit_id}).where.not(lost_reason_id: [nil, 57, 49]).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: current_personnel.business_unit_id}).where.not(lost_reason_id: nil, site_visited_on: nil).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: current_personnel.business_unit_id}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				end
			end
		elsif current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: nil).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: [nil, 57, 49]).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: nil, site_visited_on: nil).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil).where('source_categories.heirarchy like ?', '%'+SourceCategory.find(params[:lost][:source_category_id].to_i).heirarchy+'%')
				end
			end
		elsif current_personnel.status=='Team Lead'
			team_members=current_personnel.member_array	
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: team_members}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: team_members}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: team_members}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: team_members}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		else
			if params[:site_visited] == nil
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: current_personnel.id}).where.not(lost_reason_id: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: current_personnel.id}).where.not(lost_reason_id: [nil, 57, 49])
				end
			else
				if params[:without_test_duplicate] == nil
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: current_personnel.id}).where.not(lost_reason_id: nil, site_visited_on: nil)
				else
					@lost_reason_leads=Lead.includes(:personnel, :business_unit, :follow_ups, :source_category).where(source_category_id: params[:lost][:source_category_id], :personnels => {id: current_personnel.id}).where.not(lost_reason_id: [nil, 57, 49], site_visited_on: nil)
				end
			end
		end
	end
	
	if params[:lost] != nil && params[:lost][:logic]=='Based on Generation'
		@lost_logic_selected='Based on Generation'
		@lost_reason_leads=@lost_reason_leads.where('leads.generated_on >= ? and leads.generated_on < ?', @from.to_date.beginning_of_day, @to.to_date.beginning_of_day+1.day)
		week_0=@lost_reason_leads.where('leads.generated_on >= ? and leads.generated_on <= ?', @from.to_date, @from.to_date.end_of_week)
		week_1=@lost_reason_leads.where('leads.generated_on >= ? and leads.generated_on <= ?', (@from.to_date+7.days).beginning_of_week, (@from.to_date+7.days).end_of_week)
		week_2=@lost_reason_leads.where('leads.generated_on >= ? and leads.generated_on <= ?', (@from.to_date+14.days).beginning_of_week, (@from.to_date+14.days).end_of_week)
		week_3=@lost_reason_leads.where('leads.generated_on >= ? and leads.generated_on <= ?', (@from.to_date+21.days).beginning_of_week, (@from.to_date+21.days).end_of_week)
		if (@from.to_date+28.days).end_of_week.month == @month
			week_4=@lost_reason_leads.where('leads.generated_on >= ? and leads.generated_on <= ?', (@from.to_date+28.days).beginning_of_week, (@from.to_date+28.days).end_of_week)
		else
			week_4=@lost_reason_leads.where('leads.generated_on >= ? and leads.generated_on <= ?', (@from.to_date+28.days).beginning_of_week, @from.to_date.end_of_month)
		end
	else 
		p "inserting here"
		p "============================="
		@lost_reason_leads = @lost_reason_leads.where('leads.booked_on >= ? and leads.booked_on < ?', @from.to_datetime.beginning_of_day, @to.to_datetime.beginning_of_day+1.day)
		week_0 = @lost_reason_leads.where('leads.booked_on >= ? and leads.booked_on < ?', @from.to_datetime.beginning_of_day, @from.to_datetime.beginning_of_day.end_of_week+1.day)
		week_1 = @lost_reason_leads.where('leads.booked_on >= ? and leads.booked_on < ?', (@from.to_datetime.beginning_of_day+7.days).beginning_of_week, (@from.to_datetime.beginning_of_day+7.days).end_of_week+1.day)
		week_2 = @lost_reason_leads.where('leads.booked_on >= ? and leads.booked_on < ?', (@from.to_datetime.beginning_of_day+14.days).beginning_of_week, (@from.to_datetime.beginning_of_day+14.days).end_of_week+1.day)
		week_3 = @lost_reason_leads.where('leads.booked_on >= ? and leads.booked_on < ?', (@from.to_datetime.beginning_of_day+21.days).beginning_of_week, (@from.to_datetime.beginning_of_day+21.days).end_of_week+1.day)
		if (@from.to_date+28.days).end_of_week.month == @month
			week_4 = @lost_reason_leads.where('leads.booked_on >= ? and leads.booked_on < ?', (@from.to_datetime.beginning_of_day+28.days).beginning_of_week, (@from.to_datetime.beginning_of_day+28.days).end_of_week+1.day)
		else
			week_4 = @lost_reason_leads.where('leads.booked_on >= ? and leads.booked_on < ?', (@from.to_datetime.beginning_of_day+28.days).beginning_of_week, @from.to_datetime.beginning_of_day.end_of_month+1.day)
		end
	end
	
	@weeks = [week_0,week_1,week_2,week_3,week_4]
	@lost_reason_wise_leads = @lost_reason_leads.group("leads.lost_reason_id").count
	@lost_reason_wise_project_wise_leads = @lost_reason_leads.group("business_units.name","leads.lost_reason_id").count

	@project_wise_total={}
	
	@lost_reason_wise_leads.each do |key, value|
		@lost_reason_wise_project_wise_leads.keys.map{ |x| x[0] }.uniq.each do |project|
		  if @project_wise_total[project]==nil
		  	 if @lost_reason_wise_project_wise_leads[[project,key]]==nil
		  	 else	
		  	 @project_wise_total[project]=@lost_reason_wise_project_wise_leads[[project,key]]
		  	 end
		  else
		   if @lost_reason_wise_project_wise_leads[[project,key]]==nil
		   else
		   @project_wise_total[project]=@project_wise_total[project]+@lost_reason_wise_project_wise_leads[[project,key]]
		   end
		  end
		end
	end
end


def unallocated_leads
	@leads=Lead.where(personnel_id: nil)
end

def pending_followups
	@age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
	@areas = selections_with_other(Area, :name).sort
	@occupations=selections_with_other(Occupation, :description).sort
	@lost_reasons=selections(LostReason, :description)
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status == "Audit"
		if params[:executive]==nil
			@executive=current_personnel.id
		else
			@executive=params[:executive].to_i	
		end
		if current_personnel.status == "Audit"
			@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.lost_reason_id is not ?', nil).where(:leads => { :personnel_id => @executive })
		else
			@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => @executive })
		end
	elsif current_personnel.status=='Team Lead'
		@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => current_personnel.member_array } )	
	else	
		@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => current_personnel.id })
	end
	if current_personnel.status == "Audit"
		@day_1_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+1.day, Date.today+2.days).where('leads.lost_reason_id is not ?', nil).count
		@day_2_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+2.day, Date.today+3.days).where('leads.lost_reason_id is not ?', nil).count
		@day_3_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+3.day, Date.today+4.days).where('leads.lost_reason_id is not ?', nil).count
		@day_4_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+4.day, Date.today+5.days).where('leads.lost_reason_id is not ?', nil).count
		@day_5_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+5.day, Date.today+6.days).where('leads.lost_reason_id is not ?', nil).count
		@day_6_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+6.day, Date.today+7.days).where('leads.lost_reason_id is not ?', nil).count
		@day_7_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+7.day, Date.today+8.days).where('leads.lost_reason_id is not ?', nil).count
	else
		@day_1_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+1.day, Date.today+2.days).count
		@day_2_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+2.day, Date.today+3.days).count
		@day_3_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+3.day, Date.today+4.days).count
		@day_4_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+4.day, Date.today+5.days).count
		@day_5_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+5.day, Date.today+6.days).count
		@day_6_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+6.day, Date.today+7.days).count
		@day_7_count=@leads.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+7.day, Date.today+8.days).count
	end
	# @common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
	@common_followup_remarks = ["Lead Rescheduled", "Lead transferred"]
end

def followup_due
	@age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
	@areas = selections_with_other(Area, :name).sort
	@occupations=selections_with_other(Occupation, :description).sort
	@lost_reasons=selections(LostReason, :description)	
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status == "Audit"
		if params[:executive]==nil
			@executive=current_personnel.id
		else
			@executive=params[:executive].to_i	
		end
		if current_personnel.access_right == 4
			if current_personnel.id == 274
				start_date = "01/09/2021"
			else
				start_date = "16/06/2022"
			end
			@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time >= ? AND follow_ups.follow_up_time <= ?', start_date.to_datetime, Date.today+1.day).where('leads.lost_reason_id is not ?', nil).where(:leads => { :personnel_id => @executive })
			@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time >= ? AND follow_ups.follow_up_time <= ?', start_date.to_datetime, Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => @executive })
		else
			@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => @executive })
		end
	elsif current_personnel.status=='Team Lead'
		@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => current_personnel.member_array }).sort	
	else	
		@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => current_personnel.id })
	end
	@common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
end

def mobile_number_search
	if params==nil
		@leads=nil
	elsif params.select{|key, value| value == ">" }.keys[0] != nil
		redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])
	elsif params['id_search']=='Search'
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Team Lead' || current_personnel.status == 'Audit'
		@leads=Lead.includes(:source_category).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where(id: params[:id].to_i)
		else
		@leads=Lead.where(id: params[:id].to_i, personnel_id: current_personnel.id)	
		end	
	elsif params['mobile_search']=='Search'
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Team Lead' || current_personnel.status == "Audit"
		@leads=Lead.includes(:source_category).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where(mobile: params[:mobile_no])
		@leads+=Lead.includes(:source_category).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where(other_number: params[:mobile_no])
		else
		@leads=Lead.where(mobile: params[:mobile_no], personnel_id: current_personnel.id)
		@leads+=Lead.where(other_number: params[:mobile_no], personnel_id: current_personnel.id)	
		end
	elsif params['email_search']=='Search'
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Team Lead' || current_personnel.status == 'Audit'
		@leads=Lead.includes(:source_category).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where(email: params[:email])
		else
		@leads=Lead.where(email: params[:email], personnel_id: current_personnel.id)	
		end
	elsif params['name_search']=='Search'
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Team Lead' || current_personnel.status == 'Audit'
		@leads=Lead.includes(:source_category).where(:source_categories => {organisation_id: current_personnel.organisation_id}).where("lower(replace(leads.name, ' ', '')) like ?", '%' + params[:name].downcase.gsub(/\s+/, "")+ '%')		
		else
		@leads=Lead.where(personnel_id: current_personnel.id).where("lower(replace(name, ' ', '')) like ?", '%' + params[:name].downcase.gsub(/\s+/, "")+ '%')		
		end
	end
end

def fresh_leads
	@age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
	@areas = selections_with_other(Area, :name).sort
	@occupations=selections_with_other(Occupation, :description).sort
	# if current_personnel.organisation_id == 1
	# 	@lost_reasons = []
	# 	LostReason.where(description: "INVALID NUMBER").each do |lost_reason|
	# 		@lost_reasons += [[lost_reason.description, lost_reason.id]]
	# 	end
	# else
		@lost_reasons=selections(LostReason, :description)
	# end
	
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
		if params[:executive]==nil
			@executive=current_personnel.id
		else
			@executive=params[:executive].to_i	
		end
		@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => [nil,false] }).where('leads.personnel_id = ?',@executive)
	elsif current_personnel.status=='Team Lead'
		@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => [nil,false] }).where(:leads => { :personnel_id => current_personnel.member_array } )	
	else	
		@leads=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => [nil,false] }).where('leads.personnel_id = ?',current_personnel.id)
	end
	@common_templates=[]
	@whatsapp_templates=[]
	@email_templates=[]
	@sms_templates=[]
	WhatsappTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |whatsapp_template|
      @whatsapp_templates+=[[whatsapp_template.title, whatsapp_template.id]]
    end
    EmailTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |email_template|
      @email_templates+=[[email_template.title, email_template.id]]
    end
	@common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry']
	# @all_templates=[@whatsapp_templates, @email_templates, @sms_templates]
	# @common_templates=@all_templates.inject(:&)
	# @common_templates.each do |common_template|
	# 	@whatsapp_templates.delete(common_template)
	# 	@email_templates.delete(common_template)
	# 	@sms_templates.delete(common_template)
	# end
end

def booked_leads
	@source_categories=selections(SourceCategory.where(inactive: [nil,false]), :heirarchy)
	@source_categories=[['All Categories ',-1]]+@source_categories
	if params[:range] == nil
		@source_category_selected=-1
	else
		@source_category_selected=params[:salesteam][:source_category_id]	
	end
	@from=(Date.today)-30
	@to=(Date.today)+1
	@with_children = params[:with_children]
	@with_cancellation = params[:with_cancellation]

	if params[:range]!=nil
	   @from=params[:range][:from]
	   @to=params[:range][:to]
    end
    if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
    	@projects = [["Dream Gurukul", 70]]
    else
    	@projects=selections_with_all(BusinessUnit, :name)
    end
	if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	else
		if params[:project][:selected]=='-1'
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			project_selected=params[:project][:selected]
		end
	end

	if current_personnel.status=='Team Lead'
		@sales_team=[[' All', -1]]
        current_personnel.member_array.each do |team_member|
        	@sales_team+=[[Personnel.find(team_member).name, team_member]] 
    	end
		if params[:salesteam]==nil
			@sales_person=-1
		elsif params[:salesteam][:personnel]==-1
			@sales_person=-1
		else
			@sales_person=params[:salesteam][:personnel].to_i	
		end
		if @sales_person == -1 
			@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {predecessor: current_personnel.id},:leads => {business_unit_id: project_selected}).where('leads.booked_on_on >= ? AND leads.booked_on < ?', @from, ((@to.to_date)+1.day))
		else
			@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {predecessor: current_personnel.id}).where('leads.booked_on >= ? AND leads.booked_on < ? AND leads.business_unit_id = ? AND leads.personnel_id = ?', @from, ((@to.to_date)+1.day), project_selected, @sales_person)
		end
	elsif current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
		@sales_team=selections_with_all(Personnel, :name)	
		if params[:salesteam]==nil
			@sales_person=-1
		elsif params[:salesteam][:personnel]==-1
			@sales_person=-1
		else
			@sales_person=params[:salesteam][:personnel].to_i	
		end
		if @sales_person==-1
			@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {organisation_id: current_personnel.organisation_id},:leads => {business_unit_id: project_selected}).where('leads.booked_on >= ? AND leads.booked_on < ?', @from, ((@to.to_date)+1.day))
		else
			@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {organisation_id: current_personnel.organisation_id}).where('leads.booked_on >= ? AND leads.booked_on < ? AND leads.business_unit_id = ? AND leads.personnel_id = ?', @from, ((@to.to_date)+1.day), project_selected, @sales_person)
		end	
	else
		@sales_team=selections_with_all(Personnel, :name)	
		p "working here"
		p "============================="
		@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {organisation_id: current_personnel.organisation_id}).where('leads.booked_on >= ? AND leads.booked_on < ? AND leads.business_unit_id = ? AND leads.personnel_id = ?', @from, ((@to.to_date)+1.day), project_selected, @sales_person)
	end
	if @source_category_selected == "-1" || @source_category_selected == -1
		if params[:with_cancellation] == nil
			@leads = @leads.where(status: true, lost_reason_id: nil, cancelled_on: nil)
		else
			@leads = @leads.where(status: true,lost_reason_id: nil)
		end
	else
		if @with_children == nil 
			if params[:with_cancellation] == nil
				p "working here"
				p "============================="
				@leads = @leads.where(source_category_id: @source_category_selected.to_i,status: true,lost_reason_id: nil, cancelled_on: nil)
			else
				@leads = @leads.where(source_category_id: @source_category_selected.to_i,status: true,lost_reason_id: nil)
			end
		else
			if params[:with_cancellation] == nil
				@leads = @leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where(status: true, lost_reason_id: nil, cancelled_on: nil)
			else
				@leads = @leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where(status: true, lost_reason_id: nil)
			end
		end
	end
	@flats=[]
	Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
		@flats+=[[(flat.block.business_unit.name+','+flat.block.name+','+flat.name), flat.id]]
	end		
end

def flat_rate_update
	if params.select{|key, value| value == ">" }.keys[0] == nil
	lead_id=params[:lead_id]
	Flat.find(params[:booked][:flat]).update(lead_id: lead_id.to_i, rate: params[:remarks].to_i, status: true)
	redirect_to :back
	else
	redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
	end
end

def site_visited_leads
	@source_categories=selections(SourceCategory.where(inactive: [nil,false]), :heirarchy)
	@source_categories=[['All Categories',-1]]+@source_categories
	if params[:range] == nil
		@source_category_selected = -1
	else
		if params[:salesteam] == nil
			@source_category_selected= -1
		else
			@source_category_selected = params[:salesteam][:source_category_id]	
		end
	end
	if params[:with_children] == nil
	else
		@with_children=params[:with_children]
	end
	lost_reasons = LostReason.where(organisation_id: 1).pluck(:id)
	lost_reasons = lost_reasons-[57,49]
	lost_reasons = lost_reasons+[nil]
	if params.select{|key, value| value == ">" }.keys[0] == nil
		if current_personnel.email == "riddhi.gadhiya@beyondwalls.com" || current_personnel.email == "pranabeshpratiharjgm@gmail.com"
			@projects = [["Dream Gurukul", 70]]
		else
			@projects=selections_with_all(BusinessUnit, :name)
		end
		if params[:project]==nil
			project_selected = BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			if params[:project][:selected] == '-1'
				project_selected = BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
				project_selected = params[:project][:selected]
			end
		end
		if params[:range] == nil
			@from = (Date.today)-60
			@to = (Date.today)+1
		else
			@from = params[:range][:from]
			@to = params[:range][:to]
		end

		@to=@to.to_datetime.end_of_day
		@from=@from.to_datetime.beginning_of_day
	
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status == "Audit"
			@sales_team = site_executives = selections_with_all_active(Personnel, :name)
			if params[:refresh]=='Refresh'
			   @sales_person=params[:salesteam][:personnel].to_i
		    else
			   @sales_person = -1
			end
			if @sales_person == -1
				@leads = Lead.includes(:business_unit, :source_category, :personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit_id: project_selected, lost_reason_id: lost_reasons).where('site_visited_on >= ? AND site_visited_on <= ?', @from, @to)
			else
				@leads = Lead.includes(:business_unit, :source_category, :personnel).where('site_visited_on >= ? AND site_visited_on <= ?', @from, @to).where(personnel_id: @sales_person, business_unit_id: project_selected, lost_reason_id: lost_reasons)
			end
		elsif current_personnel.status=='Team Lead'
			team_members = current_personnel.member_array
			@leads = Lead.includes(:business_unit, :source_category, :personnel).where('site_visited_on >= ? AND site_visited_on <= ?', @from, @to).where(personnel_id: team_members, business_unit_id: project_selected, lost_reason_id: lost_reasons)
		else
			@leads = Lead.includes(:business_unit, :source_category, :personnel).where('site_visited_on >= ? AND site_visited_on <= ?', @from, @to).where(personnel_id: current_personnel.id, business_unit_id: project_selected, lost_reason_id: lost_reasons)
		end
		if @source_category_selected == "-1" || @source_category_selected == -1
		else
			if @with_children == nil 
				@leads = @leads.where(source_category_id: @source_category_selected.to_i).where.not(site_visited_on: nil)
			else
				@leads = @leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.site_visited_on is not ?', nil)
			end
		end
	else
		redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])
	end
end

def lost_leads
	@source_categories=selections(SourceCategory.where(inactive: [nil,false]), :heirarchy)
	@source_categories=[['All Categories',-1]]+@source_categories
	if params[:range] == nil
		@source_category_selected=-1
	else
		@source_category_selected=params[:salesteam][:source_category_id]	
	end
	@lead_types = ['All Types','Site Visited','Not Site Visited']
	@with_children=params[:with_children]
	if params.select{|key, value| value == ">" }.keys[0] == nil
		@from=(Date.today)-7
		@to=(Date.today)+1
		if params[:range]!=nil
		   @from=params[:range][:from]
		   @to=params[:range][:to]
	    end
    	# @type_selected='All'
    	if params[:lost] == nil 
    		@type_selected = 'All Types'
    	else
    		@type_selected = params[:lost][:type]
    	end
	    # @type_selected = params[:lost][:type] if params[:lost]!=nil
		if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
	    	@projects=[]
			BusinessUnit.where(organisation_id: 1).each do |business_unit|
				if business_unit.name == "Dream Gurukul"
					@projects += [[business_unit.name, business_unit.id]]
				end
			end
		else
			@projects=selections_with_all(BusinessUnit, :name)
		end
		
		if params[:project]==nil
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			if params[:project][:selected]=="-1"
				project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
				project_selected=params[:project][:selected]
			end
		end		
		@lost_reasons=selections_with_all(LostReason, :description)
		if params[:lost_reason]==nil
			lost_reason=LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			if params[:lost_reason][:selected]=="-1"
				lost_reason=LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
				lost_reason=params[:lost_reason][:selected]
			end
		end		
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
			@sales_team=selections_with_all(Personnel, :name)	
			if params[:salesteam]==nil
				@sales_person="-1"
			elsif params[:salesteam][:personnel]=="-1"
				@sales_person="-1"
			else
				@sales_person=params[:salesteam][:personnel].to_i	
			end
			if @sales_person=="-1"
				if @type_selected == 'All Types'
					@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.status = ? AND leads.booked_on >= ? AND leads.booked_on <= ?', true, @from.to_datetime.beginning_of_day, @to.to_datetime.end_of_day).where(business_unit_id: project_selected, lost_reason_id: lost_reason)
				else
					if @type_selected == 'Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.booked_on >= ? AND leads.booked_on <= ?', @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason).where('leads.site_visited_on is not ?', nil)
					elsif @type_selected == 'Not Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.booked_on >= ? AND leads.booked_on <= ?', @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason).where('leads.site_visited_on is ?', nil)
					elsif @type_selected == 'Visit Organised but not Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.status = ? AND leads.booked_on >= ? AND leads.booked_on <= ?', true, @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason, osv: true)
					end
					# @leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason)
				end
				# @leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason)
			else
				if @type_selected == 'All Types'
					@leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason)
				else
					if @type_selected == 'Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('booked_on >= ? AND booked_on <= ?', @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason).where('leads.site_visited_on is not ?', nil)
					elsif @type_selected == 'Not Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('booked_on >= ? AND booked_on <= ?', @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason).where('leads.site_visited_on is ?', nil)
					elsif @type_selected == 'Visit Organised but not Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason, osv: true)
					end
					# @leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason)
				end
				# @leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason)
			end
		elsif current_personnel.status=='Team Lead'
			@sales_team=[[' All', -1]]
	        current_personnel.member_array.each do |team_member|
	        	@sales_team+=[[Personnel.find(team_member).name, team_member]] 
	        end	
			
			if params[:salesteam]==nil
				@sales_person="-1"
			elsif params[:salesteam][:personnel]=="-1"
				@sales_person="-1"
			else
				@sales_person=params[:salesteam][:personnel].to_i	
			end

			if @from.to_date<Date.today-90.days
			   	@from=Date.today-90.days
			end

			if @sales_person=="-1"
				if @type_selected == 'All Types'
					@leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, nil, @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason)
				else
					if @type_selected == 'Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('booked_on >= ? AND booked_on <= ?', @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason).where('osv = ? AND status= ?', nil, false)
					elsif @type_selected == 'Not Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('booked_on >= ? AND booked_on <= ?',@from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason).where.not(osv: nil, status: false)
					elsif @type_selected == 'Visit Organised but not Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, nil, @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason, osv: true)
					end
				end
				# @leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, nil, @from, @to).where(business_unit_id: project_selected, lost_reason_id: lost_reason)
			else
				if @type_selected == 'All Types'
					@leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, nil, @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason)
				else
					if @type_selected == 'Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('booked_on >= ? AND booked_on <= ?', @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason).where('osv = ? AND status= ?', nil, false)
					elsif @type_selected == 'Not Site Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('booked_on >= ? AND booked_on <= ?', @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason).where.not(osv: nil, status: false)
					elsif @type_selected == 'Visit Organised but not Visited'
						@leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, nil, @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason, osv: true)
					end
				end
				# @leads=Lead.includes(:business_unit, :source_category, :personnel).where('status = ? AND booked_on >= ? AND booked_on <= ?', true, nil, @from, @to).where(business_unit_id: project_selected, personnel_id: @sales_person, lost_reason_id: lost_reason)
			end
		else
			if @type_selected == 'All Types'
				@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.status = ? OR leads.status =? AND leads.booked_on >= ? AND leads.booked_on <= ?', true, nil, @from, @to).where(personnel_id: current_personnel.id, lost_reason_id: lost_reason)
			else
				if @type_selected == 'Site Visited'
					@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.booked_on >= ? AND leads.booked_on <= ?', @from, @to).where(personnel_id: current_personnel.id, lost_reason_id: lost_reason).where('leads.osv = ? AND leads.status= ?', nil, false)
				elsif @type_selected == 'Not Site Visited'
					@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.booked_on >= ? AND leads.booked_on <= ?', true, nil, @from, @to).where(personnel_id: current_personnel.id, lost_reason_id: lost_reason).where.not(osv: nil, status: false)
				elsif @type_selected == 'Visit Organised but not Visited'
					@leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.status = ? OR leads.status =? AND leads.booked_on >= ? AND leads.booked_on <= ?', true, nil, @from, @to).where(personnel_id: current_personnel.id, lost_reason_id: lost_reason, osv: true)
				end
			end
			# @leads=Lead.includes(:business_unit, :source_category, :personnel).where('leads.status = ? OR leads.status =? AND leads.booked_on >= ? AND leads.booked_on <= ?', true, nil, @from, @to).where(personnel_id: current_personnel.id, lost_reason_id: lost_reason)
		end

		if @source_category_selected == "-1" || @source_category_selected == -1
		else
			if @with_children == nil 
				@leads=@leads.where('leads.source_category_id = ?', @source_category_selected.to_i)
			else
				if @leads == []
				else
					@leads=@leads.where(status: true).where('source_categories.heirarchy like ? and leads.lost_reason_id is not ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%', nil).references(:source_category)
				end
			end
		end
	elsif params.select{|key, value| value == ">" }.keys[0] != nil
		redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
	end
end

def all_leads
	if params.select{|key, value| value == ">" }.keys[0] != nil
		redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])
	else
		@lost_reasons = selections_with_all(LostReason, :description)
		lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
	    lost_reasons = lost_reasons-[57,49]
	    lost_reasons = lost_reasons+[nil]
		if params[:lost_reason]==nil
			@selected_lost_reason ="-1"
		else
			@selected_lost_reason=params[:lost_reason][:selected]
		end
		
		if current_personnel.email == "rima.bhadra@techshu.in"
	  		@source_categories=selections(SourceCategory.where(inactive: [nil,false]).where('heirarchy like ?', "%Online%"), :heirarchy)
		else
			@source_categories=selections(SourceCategory.where(inactive: [nil,false]), :heirarchy)
			@source_categories=[['All Categories',-1]]+@source_categories
		end

		if params[:range] == nil
			@source_category_selected=-1
		else
			@source_category_selected=params[:salesteam][:source_category_id]	
		end	
		@from = (Date.today)-3
		@to = (Date.today)+1
		@with_children = params[:with_children]
		@no_duplicate = params[:no_duplicate]
	  	@lead_types=['All', 'Qualified', 'Interested in Site Visit', 'Lost', 'Site Visit', 'Booked' ]
	  	if params[:lead_type] == nil
	  		@lead_type = 'All'
	  	else
	  		@lead_type = params[:lead_type]
	  	end
	  	if current_personnel.email == "riddhi.gadhiya@beyondwalls.com"
	  		@projects=[]
			BusinessUnit.where(organisation_id: 1).each do |business_unit|
				if business_unit.name == "Dream Gurukul"
					@projects += [[business_unit.name, business_unit.id]]
				end
			end
	  	else
	  		@projects=selections_with_all(BusinessUnit, :name)
	  	end
		if params[:project]==nil
			if current_personnel.organisation_id == 1
				project_selected = [5]
			else
				project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			end
		else
			if params[:project][:selected]=="-1"
				project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
				project_selected=params[:project][:selected]
			end
		end

		if params[:export]=='Export'
			all_lead_export=AllLeadExport.new
			all_lead_export.project_id=params[:project][:selected]
			all_lead_export.personnel_id=params[:salesteam][:personnel]
			all_lead_export.source_category_id=params[:salesteam][:source_category_id]
			all_lead_export.from=params[:range][:from]
			all_lead_export.to=params[:range][:to]
			all_lead_export.email=current_personnel.email
			all_lead_export.save
		else
		  	if params[:range] != nil
			    @from=params[:range][:from]
			    @to=params[:range][:to]
		  	end
		end
	  	if current_personnel.status=='Team Lead'
			@sales_team=[[' All', -1]]
	        current_personnel.member_array.each do |team_member|
	        @sales_team+=[[Personnel.find(team_member).name, team_member]] 
	    	end	
			if params[:salesteam]==nil
				@sales_person = "-1"
			elsif params[:salesteam][:personnel] == "-1"
				@sales_person = "-1"
			else
				@sales_person = params[:salesteam][:personnel].to_i	
			end
		
			if @sales_person == "-1" 
				if @no_duplicate == nil
					@leads = Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {predecessor: current_personnel.id},:leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day)
				else
					@leads = Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {predecessor: current_personnel.id},:leads => {business_unit_id: project_selected, lost_reason_id: lost_reasons}).where('leads.generated_on >= ? AND leads.generated_on < ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day)
				end
			else
				if @no_duplicate == nil
					@leads = Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {predecessor: current_personnel.id}).where('leads.generated_on >= ? AND leads.generated_on < ? AND leads.business_unit_id = ? AND leads.personnel_id = ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day, project_selected, @sales_person)
				else
					@leads = Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {predecessor: current_personnel.id}, :leads => {lost_reason_id: lost_reasons}).where('leads.generated_on >= ? AND leads.generated_on < ? AND leads.business_unit_id = ? AND leads.personnel_id = ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day, project_selected, @sales_person)
				end
			end
		else
			@sales_team=selections_with_all(Personnel, :name)	
			if params[:salesteam]==nil
				@sales_person = "-1"
			elsif params[:salesteam][:personnel] == "-1"
				@sales_person = "-1"
			else
				if current_personnel.access_right == "Sales Executive"
					@sales_person = current_personnel.id
				else
					@sales_person=params[:salesteam][:personnel].to_i
				end
			end

			if @sales_person == "-1"
				if @selected_lost_reason == "-1"
					@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {organisation_id: current_personnel.organisation_id},:leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day)
				else
					@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {organisation_id: current_personnel.organisation_id},:leads => {business_unit_id: project_selected}).where('leads.generated_on >= ? AND leads.generated_on < ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day).where(lost_reason_id: @selected_lost_reason.to_i)
				end
			else
				if @selected_lost_reason == "-1"
					@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {organisation_id: current_personnel.organisation_id}).where('leads.generated_on >= ? AND leads.generated_on < ? AND leads.business_unit_id = ? AND leads.personnel_id = ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day, project_selected, @sales_person)
				else
					@leads=Lead.includes(:business_unit, :source_category, :personnel, :lost_reason, :follow_ups, :whatsapps).where(:personnels => {organisation_id: current_personnel.organisation_id}).where('leads.generated_on >= ? AND leads.generated_on < ? AND leads.business_unit_id = ? AND leads.personnel_id = ?', (@from.to_datetime-5.hours-30.minutes), (@to.to_datetime-5.hours-30.minutes)+1.day, project_selected, @sales_person).where(lost_reason_id: @selected_lost_reason.to_i)
				end
			end
		end
		if @source_category_selected == "-1" || @source_category_selected == -1
		else
			if @with_children == nil 
				if @lead_type == nil || @lead_type == 'All'
					@leads=@leads.where(source_category_id: @source_category_selected.to_i)
				elsif @lead_type == 'Site Visit'
					@leads=@leads.where(source_category_id: @source_category_selected.to_i).where.not(site_visited_on: nil)
				elsif @lead_type == 'Booked'
					@leads=@leads.where(source_category_id: @source_category_selected.to_i,status: true,lost_reason_id: nil)
				elsif @lead_type == 'Lost'
					@leads=@leads.where('leads.status = ? and leads.lost_reason_id is not ? ', true, nil).where(source_category_id: @source_category_selected.to_i)
				elsif @lead_type == 'Qualified'
					@leads=@leads.where('leads.qualified_on is not ?', nil).where(source_category_id: @source_category_selected.to_i)
				elsif @lead_type == 'Interested in Site Visit'
					@leads=@leads.where('leads.interested_in_site_visit_on is not ?', nil).where(source_category_id: @source_category_selected.to_i)
				end
			else
				if @lead_type == nil || @lead_type == 'All'
					if @no_duplicate == nil || @no_duplicate == ""
						@leads=@leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%')
					else
						@leads = @leads.where(lost_reason_id: lost_reasons).where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%')
					end
				elsif @lead_type == 'Site Visit'
					if @no_duplicate == nil || @no_duplicate == ""
						@leads=@leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.site_visited_on is not ?', nil)
					else
						@leads=@leads.where(lost_reason_id: lost_reasons).where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.site_visited_on is not ?', nil)
					end
				elsif @lead_type == 'Booked'
					if @no_duplicate == nil || @no_duplicate == ""
						@leads=@leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where(status: true, lost_reason_id: nil)
					else
						@leads=@leads.where(lost_reason_id: lost_reasons).where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where(status: true, lost_reason_id: nil)
					end
				elsif @lead_type == 'Lost'
					if @no_duplicate == nil || @no_duplicate == ""
						@leads=@leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.status = ? and leads.lost_reason_id is not ? ', true, nil)
					else
						@leads=@leads.where(lost_reason_id: lost_reasons).where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.status = ? and leads.lost_reason_id is not ? ', true, nil)
					end
				elsif @lead_type == 'Qualified'
					if @no_duplicate == nil || @no_duplicate == ""
						@leads=@leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.qualified_on is not ?', nil)
					else
						@leads=@leads.where(lost_reason_id: lost_reasons).where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.qualified_on is not ?', nil)
					end
				elsif @lead_type == 'Interested in Site Visit'
					if @no_duplicate == nil || @no_duplicate == ""
						@leads=@leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.interested_in_site_visit_on is not ?', nil)
					else
						@leads=@leads.where(lost_reason_id: lost_reasons).where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%').where('leads.interested_in_site_visit_on is not ?', nil)
					end
				end
				# @leads=@leads.where('source_categories.heirarchy like ?', '%'+(SourceCategory.find(@source_category_selected).heirarchy)+'%')
			end
		end
	end
end

def all_followups
	site_executives=selections(Personnel, :name)
	  @from=(Date.today)-7
  	  @to=(Date.today)
      if params[:follow_up] != nil
      @from=params[:follow_up][:from]
      @to=params[:follow_up][:to]
      end
    if current_personnel.status=='Team Lead'
    @followups=FollowUp.includes(:personnel).where(:personnels => {predecessor: current_personnel.id}).where('follow_ups.communication_time >= ? AND follow_ups.communication_time <= ?', @from, @to)
	else  
	@followups=FollowUp.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}).where('follow_ups.communication_time >= ? AND follow_ups.communication_time <= ?', @from, @to)
	end
end


def template_send
	if params[:whatsapp_template] == nil || params[:whatsapp_template] == ''
	else
		whatsapp_template_with_lead=params[:whatsapp_template]
		position=whatsapp_template_with_lead.index('*')
		whatsapp_template=whatsapp_template_with_lead[0..position-1]
		lead_id=whatsapp_template_with_lead[position+1..whatsapp_template_with_lead.length]
		@lead=Lead.find(lead_id.to_i)
		@whatsapp_template=WhatsappTemplate.find_by_title(whatsapp_template.to_s)
		urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(@lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(@lead.mobile))
      	result = HTTParty.get(urlstring)
		if result.parsed_response['result'] != 'not exists'            
			# if @whatsapp_template.whatsapp_images==[]
				if (@whatsapp_template.file_name == nil || @whatsapp_template.file_name == '') && (@whatsapp_template.file_url == nil || @whatsapp_template.file_url == '')
					urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		            result = HTTParty.post(urlstring,
		               :body => { :to_number => '+91'+(@lead.mobile),
		                 :message => @whatsapp_template.body,    
		                  :type => "text"
		                  }.to_json,
		                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
		            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		            result = HTTParty.post(urlstring,
		               :body => { :to_number => '+91'+(current_personnel.mobile),
		                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
		                  :type => "text"
		                  }.to_json,
		                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

					template_send = TemplateSend.new
					template_send.template = @whatsapp_template.title+' sent in Whatsapp'
					template_send.lead_id = @lead.id
					template_send.save

					flash[:success]='Whatsapp send successfully.'	
				else
					urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		            result = HTTParty.post(urlstring,
		               :body => { :to_number => '+91'+(@lead.mobile),
		                 :message => @whatsapp_template.file_url,    
		                  :text => "",
		                  :type => "media"
		                  }.to_json,
		                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
		            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		            result = HTTParty.post(urlstring,
		               :body => { :to_number => '+91'+(current_personnel.mobile),
		                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
		                  :type => "text"
		                  }.to_json,
		                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

					template_send = TemplateSend.new
					template_send.template = @whatsapp_template.title+' sent in Whatsapp'
					template_send.lead_id = @lead.id
					template_send.save

					flash[:success]='Whatsapp send successfully.'
				end
			# else
			# 	urlstring =  "https://eu71.chat-api.com/instance"+@lead.business_unit.organisation.whatsapp_instance+"/sendFile?token="+@lead.business_unit.organisation.whatsapp_key
			# 	  result = HTTParty.get(urlstring,
			# 	  :body => { :phone => "91"+(@lead.mobile),
			# 	   :body => 'https:'+(@whatsapp_template.whatsapp_images[0].image.url),
			# 	             :caption => @whatsapp_template.body,
			# 	             :filename => @whatsapp_template.whatsapp_images[0].image_file_name
			# 	             }.to_json,
			# 	  :headers => { 'Content-Type' => 'application/json' } )	
	  #       	urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(@lead.personnel.organisation.whatsapp_key)
			# 	  result = HTTParty.get(urlstring,
			# 	  :body => { :phone => "91"+(current_personnel.mobile),
			# 	             :body => @whatsapp_template.title+' sent to '+@lead.name
			# 	             }.to_json,
			# 	  :headers => { 'Content-Type' => 'application/json' } )
				
			# 	template_send = TemplateSend.new
			# 	template_send.template = @whatsapp_template.title+' sent in Whatsapp'
			# 	template_send.lead_id = @lead.id
			# 	template_send.save
				
			# 	flash[:success]='Whatsapp send successfully.'
			# end
		else
			if @lead.other_number == nil || @lead.other_number == ''
	          flash[:danger]='Other Number is nil for this customer so whatsapp cannot be send'  
	        else
	          urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(@lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(@lead.other_number))
	          result = HTTParty.get(urlstring)
	            if result.parsed_response['result'] != 'not exists'
		          	# if @whatsapp_template.whatsapp_images==[]
		        		if (@whatsapp_template.file_name == nil || @whatsapp_template.file_name == '') && (@whatsapp_template.file_url == nil || @whatsapp_template.file_url == '')
							urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
				            result = HTTParty.post(urlstring,
				               :body => { :to_number => '+91'+(@lead.other_number),
				                 :message => @whatsapp_template.body,    
				                  :type => "text"
				                  }.to_json,
				                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
				            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
				            result = HTTParty.post(urlstring,
				               :body => { :to_number => '+91'+(current_personnel.mobile),
				                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
				                  :type => "text"
				                  }.to_json,
				                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

							template_send = TemplateSend.new
							template_send.template = @whatsapp_template.title+' sent in Whatsapp'
							template_send.lead_id = @lead.id
							template_send.save  

							flash[:success]='Whatsapp send successfully.'
						else
							urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
				            result = HTTParty.post(urlstring,
				               :body => { :to_number => '+91'+(@lead.other_number),
				                 :message => @whatsapp_template.file_url,    
				                  :text => "",
				                  :type => "media"
				                  }.to_json,
				                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
				            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
				            result = HTTParty.post(urlstring,
				               :body => { :to_number => '+91'+(current_personnel.mobile),
				                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
				                  :type => "text"
				                  }.to_json,
				                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

							template_send = TemplateSend.new
							template_send.template = @whatsapp_template.title+' sent in Whatsapp'
							template_send.lead_id = @lead.id
							template_send.save  

							flash[:success]='Whatsapp send successfully.'
						end  		
					# else
					# 	urlstring =  "https://eu71.chat-api.com/instance"+@lead.business_unit.organisation.whatsapp_instance+"/sendFile?token="+@lead.business_unit.organisation.whatsapp_key
					# 	  result = HTTParty.get(urlstring,
					# 	  :body => { :phone => "91"+(@lead.other_number),
					# 	   :body => 'https:'+(@whatsapp_template.whatsapp_images[0].image.url),
					# 	             :caption => @whatsapp_template.body,
					# 	             :filename => @whatsapp_template.whatsapp_images[0].image_file_name
					# 	             }.to_json,
					# 	  :headers => { 'Content-Type' => 'application/json' } )	
			  #       	urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(@lead.personnel.organisation.whatsapp_key)
					# 	  result = HTTParty.get(urlstring,
					# 	  :body => { :phone => "91"+(current_personnel.mobile),
					# 	             :body => @whatsapp_template.title+' sent to '+@lead.name
					# 	             }.to_json,
					# 	  :headers => { 'Content-Type' => 'application/json' } )

					# 	template_send = TemplateSend.new
					# 	template_send.template = @whatsapp_template.title+' sent in Whatsapp'
					# 	template_send.lead_id = @lead.id
					# 	template_send.save  

					# 	flash[:success]='Whatsapp send successfully.'
					# end
				else
					flash[:danger]='Number not active on Whatsapp'  
	      	  	end
	      	end
		end  
	end

	if params[:email_template] ==nil || params[:email_template] == ''
	else
		email_template_with_lead=params[:email_template]
		position=email_template_with_lead.index('*')
		email_template=email_template_with_lead[0..position-1]
		lead_id=email_template_with_lead[position+1..email_template_with_lead.length]
		@lead=Lead.find(lead_id.to_i)
		@email_template=EmailTemplate.find_by_title(email_template.to_s)
		if @lead.email == nil || @lead.email == ''
			flash[:danger]='Lead dont have any email id'
		else
			template_send = TemplateSend.new
			template_send.template = @email_template.title+' sent in Email'
			template_send.lead_id = @lead.id
			template_send.save

			email_data=[@email_template.id, current_personnel.id, @lead.id]
			# UserMailer.email_template_send(email_data).deliver
			
			flash[:success]='Email sent successfully.'
		end
	end

	if params[:sms_template] == nil || params[:sms_template] == ''
	else
		sms_template_with_lead=params[:sms_template]
		position=sms_template_with_lead.index('*')
		sms_template=sms_template_with_lead[0..position-1]
		lead_id=sms_template_with_lead[position+1..sms_template_with_lead.length]
		@lead=Lead.find(lead_id.to_i)
		@sms_template=SmsTemplate.find_by_title(sms_template.to_s)
		text=@sms_template.body
		text=text.to_s.gsub("\r\n","%0a")
		template_send = TemplateSend.new
		template_send.template = @sms_template.title+' sent in SMS'
		template_send.lead_id = @lead.id
		template_send.save

		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @lead.mobile + "&text=" + text.to_s + "&route=03"
		response=HTTParty.get(urlstring)
		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + current_personnel.mobile + "&text=" + text.to_s + "&route=03"
		response=HTTParty.get(urlstring)
		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + '8389822643' + "&text=" + text.to_s + "&route=03"
		response=HTTParty.get(urlstring)
	end
	
	redirect_to :back
end

def outbound
#not being used
end

def drilldown_followup_entry
	if current_personnel.organisation_id == 1
		common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred", "Called many time but the customer didn't respond", "Called many time but not reachable", "Call Forwarded", "Visited the site"]
		not_connected_call_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Incoming Call facility is not available in this number', 'Invalid Number', "Lead Rescheduled", "Lead transferred", "Called many time but the customer didn't respond", "Called many time but not reachable", "Call Forwarded", "Visited the site"]
		if params[:update] =='Update'
			if params[:telephony_call_id] == nil
			else
				correct_call = false
				false_entry = false
				telephony_call = TelephonyCall.find(params[:telephony_call_id])
				if current_personnel.email == "samanta@thejaingroup.com" || current_personnel.email == "ayush@thejaingroup.com"
				else
					if telephony_call.duration == 0.0 && telephony_call.call_type == "None" && telephony_call.call_outcome == "NA"
						if params[:remarks] == "Lead transferred"
							correct_call = true
						else
							flash[:danger] = "The lead is not updated because you are doing a flase entry in the system which is not at all considered as a followup entry. Please Call the customer again."
						end
					elsif (telephony_call.duration > 0.0 && telephony_call.call_type == "Missed" && telephony_call.call_outcome == "LegA") || (telephony_call.duration > 0.0 && telephony_call.call_type == "Missed" && telephony_call.call_outcome == "LegB")
						if not_connected_call_remarks.include?(params[:remarks]) == true
							correct_call = true
						else
							if params[:leading][:status] == '5' || params[:leading][:status] == '2'
								correct_call = true
							else
								false_entry = true
								flash[:danger] = "The lead is not updated because you are giving other remarks in place of the remarks given for not connected calls in the system."
							end
						end
					else
						correct_call = true
					end
				end
			end
			if correct_call == true || current_personnel.email == "samanta@thejaingroup.com" || current_personnel.email == "ayush@thejaingroup.com"
				rescheduled_leads = 0
				transferred_leads = 0
				data = []
				Lead.transaction do
					@followup = FollowUp.new
					@followup.lead_id = params[:leading_id].to_i
					@lead = Lead.find(@followup.lead_id)
					if current_personnel.business_unit.organisation_id == 1
						if params[:followups] == [] || params[:followups] == nil
							if params[:whatsapp_templates] == [] ||  params[:whatsapp_templates] == nil
								if params[:email_tempaltes] == [] || params[:email_tempaltes] == nil
								else
									params[:email_templates].each do |email_template_id|
										email_template = EmailTemplate.find(email_template_id)
										email_data = [email_template.id, current_personnel.id, @lead.id]
										# UserMailer.email_template_send(email_data).deliver

										template_send = TemplateSend.new
										template_send.template = email_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead.id
										template_send.save
									end
								end
							else
								if params[:email_tempaltes] == [] || params[:email_tempaltes] == nil
									if current_personnel.business_unit_id == 70
										params[:whatsapp_templates].each do |whatsapp_template_name|
											dg_pdfs = [["gurukul_brochure_mobileview", "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21751&authkey=!ALhDU300XRQYHLs&em=2"]]
											if whatsapp_template_name == "gurukul_brochure_mobileview"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.mobile.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
												if @lead.other_number == nil || @lead.other_number == ""
												else
													if @lead.other_number.length == 10
														urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
														result = HTTParty.post(urlstring,
														:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.other_number.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
														:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
														p result
														p "============project details result===================="
														whatsapp_followup = WhatsappFollowup.new
														whatsapp_followup.lead_id = @lead.id
														whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
														message_data = result.parsed_response
													  	message_id = message_data["messages"]
													  	message_id = message_id[0]["id"]
														whatsapp_followup.message_id = message_id
														whatsapp_followup.save
													end
												end
											elsif whatsapp_template_name == "gurukul_location" || whatsapp_template_name == "gurukul_project_brief"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => { "messaging_product": "whatsapp", "to": "91"+@lead.mobile.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
												if @lead.other_number == nil || @lead.other_number == ""
												else
													if @lead.other_number.length == 10
														urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
														result = HTTParty.post(urlstring,
														:body => { "messaging_product": "whatsapp", "to": "91"+@lead.other_number.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
														:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
														p result
														p "============project details result===================="
														whatsapp_followup = WhatsappFollowup.new
														whatsapp_followup.lead_id = @lead.id
														whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
														message_data = result.parsed_response
													  	message_id = message_data["messages"]
													  	message_id = message_id[0]["id"]
														whatsapp_followup.message_id = message_id
														whatsapp_followup.save
													end
												end
											end
										end
									else
										params[:whatsapp_templates].each do |whatsapp_template_id|
											whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
											if whatsapp_template.template_type == "pdf"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template.title, "link": whatsapp_template.file_url.to_s}}] } ]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											elsif whatsapp_template.template_type == "video"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url}}] } ]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											elsif whatsapp_template.template_type == "text"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => { "messaging_product": "whatsapp", "to": "91"+@lead.mobile.to_s, "type": "template", "template": { "name": whatsapp_template.title, "language": { "code": "en" } } }.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											end
										end
									end
								else
									params[:email_templates].each do |email_template_id|
										email_template = EmailTemplate.find(email_template_id)
										email_data = [email_template.id, current_personnel.id, @lead.id]
										# UserMailer.email_template_send(email_data).deliver

										template_send = TemplateSend.new
										template_send.template = email_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead.id
										template_send.save
									end
									if current_personnel.business_unit_id == 70
										params[:whatsapp_templates].each do |whatsapp_template_name|
											dg_pdfs = [["gurukul_brochure_mobileview", "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21751&authkey=!ALhDU300XRQYHLs&em=2"]]
											if whatsapp_template_name == "gurukul_brochure_mobileview"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.mobile.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
												if @lead.other_number == nil || @lead.other_number == ""
												else
													if @lead.other_number.length == 10
														urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
														result = HTTParty.post(urlstring,
														:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.other_number.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
														:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
														p result
														p "============project details result===================="
														whatsapp_followup = WhatsappFollowup.new
														whatsapp_followup.lead_id = @lead.id
														whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
														message_data = result.parsed_response
													  	message_id = message_data["messages"]
													  	message_id = message_id[0]["id"]
														whatsapp_followup.message_id = message_id
														whatsapp_followup.save
													end
												end
											elsif whatsapp_template_name == "gurukul_location" || whatsapp_template_name == "gurukul_project_brief"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => { "messaging_product": "whatsapp", "to": "91"+@lead.mobile.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
												if @lead.other_number == nil || @lead.other_number == ""
												else
													if @lead.other_number.length == 10
														urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
														result = HTTParty.post(urlstring,
														:body => { "messaging_product": "whatsapp", "to": "91"+@lead.other_number.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
														:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
														p result
														p "============project details result===================="
														whatsapp_followup = WhatsappFollowup.new
														whatsapp_followup.lead_id = @lead.id
														whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
														message_data = result.parsed_response
													  	message_id = message_data["messages"]
													  	message_id = message_id[0]["id"]
														whatsapp_followup.message_id = message_id
														whatsapp_followup.save
													end
												end
											end
										end
									else
										params[:whatsapp_templates].each do |whatsapp_template_id|
											whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
											if whatsapp_template.template_type == "pdf"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template.title, "link": whatsapp_template.file_url.to_s}}] } ]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											elsif whatsapp_template.template_type == "video"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url}}] } ]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											elsif whatsapp_template.template_type == "text"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => { "messaging_product": "whatsapp", "to": "91"+@lead.mobile.to_s, "type": "template", "template": { "name": whatsapp_template.title, "language": { "code": "en" } } }.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "============project details result===================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											end
										end
									end
								end
							end
						else
							params[:followups].each do |followup_type|
								if followup_type == "Sms Followup"
									sms_followup = SmsFollowup.new
									sms_followup.lead_id = @lead.id
									sms_followup.save
									@picked_lead=@lead
									if @picked_lead.business_unit.walkthrough==nil || @picked_lead.business_unit.walkthrough==''
										number='91'+@picked_lead.mobile
										text = "Thanks for your enquiry at "+(@picked_lead.business_unit.name)+" !! We tried calling you but could not reach you. Please let me know a good time to call you. Regards, Contact Details: "+(@picked_lead.personnel.name) + "-" + (@picked_lead.personnel.mobile) +", DGHLPR"
				  					else
										number='91'+@picked_lead.mobile
								  		text = "Thanks for your enquiry at "+(@picked_lead.business_unit.name)+" !! We tried calling you but could not reach you. Please let me know a good time to call you. Regards, Contact Details: "+(@picked_lead.personnel.name) + "-" + (@picked_lead.personnel.mobile) +", DGHLPR"
									end
			  						# if @picked_lead.personnel.organisation.whatsapp_instance == nil
							  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=DGHLPR&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=06&peid=1701160498849382833&DLTTemplateId=1707168199126192644"
									response=HTTParty.get(urlstring)
									# end
								end
								if followup_type == "Email Followup"
									if @lead.email == nil || @lead.email == ''
									else
										email_followup = EmailFollowup.new
										email_followup.lead_id = @lead.id
										email_followup.save
										data = @lead
										UserMailer.email_followup_to_lead(data).deliver
									end
								end
							end
						end
						if common_followup_remarks.include?(params[:remarks]) == true
						else
							if @lead.business_unit.name=='Dream One' || @lead.business_unit.name=='Dream One Hotel Apartment'
						    	cli_number = "+918035469961"
						    elsif @lead.business_unit.name=='Dream Eco City'
						    	cli_number = "+918035469962"
						    elsif @lead.business_unit.name=='Dream Valley'
						    	cli_number = "+918035469963"
						    elsif @lead.business_unit.name=='Ecocity Bungalows'
						    	cli_number = "+918035469964"
						    else
						    	cli_number = "+918035469965"    
						    end
						    text = "Thank you for taking the time to speak with us. Your time is valuable, and we are grateful for your attention. Do reach out to us if you have any further questions or concerns. Thank you once again. Best Regards, "+@lead.personnel.name+"-"+cli_number.to_s+" DGHLPR"
						    if @lead.mobile == nil || @lead.mobile == ""
						    else
							    urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=DGHLPR&channel=Trans&DCS=0&flashsms=0' + "&number=" +(@lead.mobile.to_s)+ "&text=" + text + "&route=06&peid=1701160498849382833&DLTTemplateId=1707168605824430121"
								response = HTTParty.get(urlstring)
							end
						end
						if params[:extra_whatsapp_message] == nil || params[:extra_whatsapp_message] == ""
						else
							urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
							result = HTTParty.post(urlstring,
							:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "918389822643", "type": "text", "text": {"preview_url": false, "body" => "testing text message pls ignore"}}.to_json,
							:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
							
							whatsapp_followup = WhatsappFollowup.new
							whatsapp_followup.lead_id = @lead.id
							whatsapp_followup.bot_message = "Agent Reply: "+params[:extra_whatsapp_message].to_s
							message_data = result.parsed_response
						  	message_id = message_data["messages"]
						  	message_id = message_id[0]["id"]
							whatsapp_followup.message_id = message_id
							whatsapp_followup.save
						end	
					end
					if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Sales Executive' || current_personnel.status == "Audit"
						if @lead.status == true
							if params[:leading][:personnel] == nil || params[:leading][:personnel] == ""
							else
								Lead.find(params[:leading_id].to_i).update(personnel_id: params[:leading][:personnel].to_i)
								@followup.personnel_id = current_personnel.id
							end
						else
							if params[:leading][:personnel] == nil || params[:leading][:personnel] == ""
							else	
								@followup.personnel_id = current_personnel.id
								Lead.find(params[:leading_id].to_i).update(personnel_id: params[:leading][:personnel].to_i)
							end
						end
					else
						@followup.personnel_id=current_personnel.id
					end
					@followup.communication_time=params[:leading][:flexible_date]
					@followup.follow_up_time=params[:leading][:followup_date]
					followup_hours=params[:leading]['followup_time(4i)'].to_i*60*60
					followup_minutes=params[:leading]['followup_time(5i)'].to_i*60
					@followup.follow_up_time=@followup.follow_up_time+followup_hours+followup_minutes
					@followup.remarks=params[:remarks]
					if current_personnel.business_unit.organisation_id == 1
						if params[:telephony_call_id] == nil || params[:telephony_call_id] == ""
							telephony_call = TelephonyCall.where(lead_id: @lead.id, untagged: true).sort_by{|x| x.created_at}.last
							if telephony_call == nil
							else
								@followup.telephony_call_id = telephony_call.id
							end
						else
							@followup.telephony_call_id = params[:telephony_call_id].to_i
						end
					end
					if params[:site_visit_feedback] == nil
					else
						@followup.feedback = params[:site_visit_feedback]
					end
					if params[:remarks] == "Lead Rescheduled"
						rescheduled_leads += 1
					elsif params[:remarks] == "Lead transferred"
						transferred_leads += 1
					end
					if params[:leading][:status]=='0'
						@lead.update(status: nil, osv: nil, lost_reason_id: nil, booked_on: nil)
						@followup.osv=nil
						@followup.status=nil	
					elsif params[:leading][:status]=='1'
						@followup.osv = true
						@followup.status = nil
						if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
							@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
							if current_personnel.business_unit_id == 70
								whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, visit_organised: true, send_after_days: 0)
								whatsapp_templates.each do |whatsapp_template|
									if whatsapp_template.name_required == true
										if whatsapp_template.template_type == "video with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "pdf with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and one link button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [
												{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},
												{"type": "body","parameters": [{"type": "text","text": @lead.name.to_s}]}
												]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										end
									else
									end
								end
							end
						elsif @lead.qualified_on == nil
							@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date])
							if current_personnel.business_unit_id == 70
								whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, visit_organised: true, send_after_days: 0)
								whatsapp_templates.each do |whatsapp_template|
									if whatsapp_template.name_required == true
										if whatsapp_template.template_type == "video with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "pdf with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and one link button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [
												{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},
												{"type": "body","parameters": [{"type": "text","text": @lead.name.to_s}]}
												]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										end
									else
									end
								end
							end
						elsif @lead.interested_in_site_visit_on == nil
							@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil, interested_in_site_visit_on: params[:leading][:flexible_date])
							if current_personnel.business_unit_id == 70
								whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, visit_organised: true, send_after_days: 0)
								whatsapp_templates.each do |whatsapp_template|
									if whatsapp_template.name_required == true
										if whatsapp_template.template_type == "video with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "pdf with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and one link button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [
												{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},
												{"type": "body","parameters": [{"type": "text","text": @lead.name.to_s}]}
												]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										end
									else
									end
								end
							end
						else
							@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil)
							if current_personnel.business_unit_id == 70
								whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, visit_organised: true, send_after_days: 0)
								whatsapp_templates.each do |whatsapp_template|
									if whatsapp_template.name_required == true
										if whatsapp_template.template_type == "video with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "pdf with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and one link button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [
												{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},
												{"type": "body","parameters": [{"type": "text","text": @lead.name.to_s}]}
												]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										end
									else
									end
								end
							end
						end
						@number='91'+@lead.mobile
						@number=@number.to_s
						if @lead.mobile == nil || @lead.mobile == ''
						else
							# if @lead.business_unit.organisation.sender_id=='LABULB'
							# 	@message="Thank you for interest in " + @lead.business_unit.name+ ", shortly our team will provide a demo of our services" + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							# else
							# 	@message="Thank you for interest in " + @lead.business_unit.name + " !! Click the following link to download QR Code required for Site Visit and oblige.%0a%0a"+ (Bitly.client.shorten('http://www.realtybucket.com/windows/download_site_visit_qr_code?lead_id='+(@lead.id.to_s)).short_url) +"%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							# end
						end
						if @lead.visit_organised_on==nil
							@lead.update(visit_organised_on: Time.now)
							# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
							# response=HTTParty.get(urlstring)
						end
					elsif params[:leading][:status]=='11'
						if @lead.virtually_visited_on != nil
						else
							@lead.update(virtually_visited_on: Time.now, booked_on: nil, lost_reason_id: nil)
						end
						@followup.status = false
						@followup.osv = nil
						if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
						elsif @lead.qualified_on == nil
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date])	
						elsif @lead.interested_in_site_visit_on == nil
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, interested_in_site_visit_on: params[:leading][:flexible_date])
						else
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
						end
					elsif params[:leading][:status]=='2'
						if @lead.site_visited_on != nil
						else
							@lead.update(site_visited_on: Time.now, booked_on: nil, lost_reason_id: nil)
							@number='91'+@lead.mobile
							@number=@number.to_s
							if @lead.business_unit.walkthrough != nil
								@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							else
								if @lead.business_unit.organisation.sender_id=='LABULB'
									@message="Thank you for meeting with us, hope you liked our demo. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
								else
									@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
								end
							end
							@email_template=EmailTemplate.find_by(business_unit_id: @lead.business_unit_id, site_visited: true, inactive: nil)
							if @email_template != nil
								if @lead.email==nil || @lead.email==''
								else
									data=[@lead.email, @email_template.id, current_personnel.id]
									# UserMailer.testing_email_send(data).deliver      
								end
							end
							@message=@message.to_s
					  # 		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
							# response=HTTParty.get(urlstring)
							if current_personnel.business_unit_id == 70
								whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, site_visited: true, send_after_days: 0)
								whatsapp_templates.each do |whatsapp_template|
									if whatsapp_template.name_required == true
										if whatsapp_template.template_type == "video with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "image with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										elsif whatsapp_template.template_type == "pdf with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
										end
									else
									end
								end
							end
						end
						@followup.status=false
						@followup.osv=nil
						if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
							
						elsif @lead.qualified_on == nil
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date])
							
						elsif @lead.interested_in_site_visit_on == nil
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, interested_in_site_visit_on: params[:leading][:flexible_date])
						else
							@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
						end
						if @lead.visit_organised_on==nil
							@lead.update(visit_organised_on: Time.now)
						end
						if @lead.business_unit_id == 2
							dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
							dlt_result = HTTParty.get(dlturlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DO Site visited&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
						elsif @lead.business_unit_id == 5
							dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
							dlt_result = HTTParty.get(dlturlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DEC Site Visited&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
						elsif @lead.business_unit_id == 6
							dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
							dlt_result = HTTParty.get(dlturlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DV Site Visited&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
						elsif @lead.business_unit_id == 3
							dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
							dlt_result = HTTParty.get(dlturlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DWC Site Visited&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
							new_add_result = HTTParty.get(addurlstring)
						end
					elsif params[:leading][:status]=='3'
						@followup.osv=nil
						@followup.status=false
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
						repeat_site_visit=RepeatVisit.new
						repeat_site_visit.follow_up_id=@followup.id
						repeat_site_visit.date=params[:leading][:flexible_date]
						repeat_site_visit.save
					elsif params[:leading][:status]=='6'
						@followup.osv=false
						@followup.status=false
						@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
						field_visited=false
						@lead.follow_ups.each do |follow_up|
							if FieldVisit.find_by_follow_up_id(follow_up.id)!=nil
								field_visited=true
							end
						end
						if field_visited==false
						field_visit=FieldVisit.new
						field_visit.follow_up_id=@followup.id
						field_visit.date=params[:leading][:flexible_date]
						field_visit.save
						end
					elsif params[:leading][:status]=='7'
						@followup.osv=false
						@followup.status=false
						@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
						field_visit=FieldVisit.new
						field_visit.follow_up_id=@followup.id
						field_visit.date=params[:leading][:flexible_date]
						field_visit.save
					elsif params[:leading][:status]=='8'
						@followup.osv=false
						@followup.status=nil
						@lead.update(status: nil, osv: false, lost_reason_id: nil, booked_on: nil)
					elsif params[:leading][:status]=='5'	
						@followup.status = true
						@followup.osv = nil
						@lead.update(status: true, osv: nil)
						@lead.update(booked_on: params[:leading][:flexible_date])
						@lead.update(lost_reason_id: params[:leading][:lost_reason])
						dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
						dlt_result = HTTParty.get(dlturlstring)
					elsif params[:leading][:status]=='4'	
						@followup.status=true
						@followup.osv=nil
						@lead.update(status: true, osv: nil, lost_reason_id: nil)
						@lead.update(booked_on: params[:leading][:flexible_date])
					elsif params[:leading][:status]=='9'
						if current_personnel.name == "Shradhya Saha" || current_personnel.name == "Moumita Mitra"
							if current_personnel.last_robin == nil
								current_personnel.update(last_robin: true)
								@lead.update(personnel_id: 156)
							elsif current_personnel.last_robin == true
								current_personnel.update(last_robin: false)
								@lead.update(personnel_id: 291)
							elsif current_personnel.last_robin == false
								current_personnel.update(last_robin: true)
								@lead.update(personnel_id: 156)
							else
								@lead.update(personnel_id: current_personnel.id)
							end
							@followup.status = false
							@followup.osv = true
							if @lead.qualified_on==nil
								@lead.update(osv: true, status: false, qualified_on: Time.now, booked_on: nil, lost_reason_id: nil)
								whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, qualified: true, send_after_days: 0)
								whatsapp_templates.each do |whatsapp_template|
									if whatsapp_template.name_required == true
										if whatsapp_template.template_type == "video with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "2", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
											whatsapp_followup = WhatsappFollowup.new
											whatsapp_followup.lead_id = @lead.id
											whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
											message_data = result.parsed_response
										  	message_id = message_data["messages"]
										  	message_id = message_id[0]["id"]
											whatsapp_followup.message_id = message_id
											whatsapp_followup.save
										elsif whatsapp_template.template_type == "image with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "2", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
											whatsapp_followup = WhatsappFollowup.new
											whatsapp_followup.lead_id = @lead.id
											whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
											message_data = result.parsed_response
										  	message_id = message_data["messages"]
										  	message_id = message_id[0]["id"]
											whatsapp_followup.message_id = message_id
											whatsapp_followup.save
										elsif whatsapp_template.template_type == "pdf with text and quickreply button"
											urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
											result = HTTParty.post(urlstring,
											:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "2", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
											:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
											p result
											p "==========================="
											whatsapp_followup = WhatsappFollowup.new
											whatsapp_followup.lead_id = @lead.id
											whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
											message_data = result.parsed_response
										  	message_id = message_data["messages"]
										  	message_id = message_id[0]["id"]
											whatsapp_followup.message_id = message_id
											whatsapp_followup.save
										end
									else
									end
								end
							else
								@lead.update(osv: true, status: false, booked_on: nil, lost_reason_id: nil)	
							end
						else
							@followup.status = false
							@followup.osv = true
							if @lead.qualified_on==nil
								@lead.update(osv: true, status: false, qualified_on: Time.now, booked_on: nil, lost_reason_id: nil)
								
							else
								@lead.update(osv: true, status: false, booked_on: nil, lost_reason_id: nil)	
							end
							if @lead.business_unit_id == 2
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead.business_unit_id == 5
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DEC Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead.business_unit_id == 6
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DV Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead.business_unit_id == 3
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DWC Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							end
						end
					elsif params[:leading][:status]=='10'
						@followup.status = false
						@followup.osv = true
						if @lead.interested_in_site_visit_on==nil
							if @lead.qualified_on == nil
								@lead.update(osv: true, status: false, qualified_on: Time.now, interested_in_site_visit_on: Time.now, booked_on: nil, lost_reason_id: nil)
								
							else
								@lead.update(osv: true, status: false, interested_in_site_visit_on: Time.now, booked_on: nil, lost_reason_id: nil)
							end
						else
							@lead.update(osv: true, status: false, booked_on: nil, lost_reason_id: nil)
						end
						if @lead.business_unit_id == 2
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
							add_result = HTTParty.get(addurlstring)
						elsif @lead.business_unit_id == 5
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DEC Qualified&mode=ADD"
							add_result = HTTParty.get(addurlstring)
						elsif @lead.business_unit_id == 6
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DV Qualified&mode=ADD"
							add_result = HTTParty.get(addurlstring)
						elsif @lead.business_unit_id == 3
							addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DWC Qualified&mode=ADD"
							add_result = HTTParty.get(addurlstring)					
						end
					end
					if params[:leading][:area_id] == ""
					else
						if params[:leading][:area_id] == "-1"
							if params[:area_other] == nil
							else
								area = Area.new
								area.name = params[:area_other]
								area.organisation_id = current_personnel.organisation_id
								area.save
								@lead.update(area_id: area.id)
							end	
						else
							@lead.update(area_id: params[:leading][:area_id])
						end
					end
					if params[:leading][:age_bracket] == ""
					else
						@lead.update(age_bracket: params[:leading][:age_bracket])
					end
					if params[:leading][:work_area_id] == ""
					else
						if params[:leading][:work_area_id] == "-1"
							if params[:work_area_other] == nil
							else
								area = Area.new
								area.name = params[:work_area_other]
								area.organisation_id = current_personnel.organisation_id
								area.save
								@lead.update(work_area_id: area.id)
							end	
						else
							@lead.update(work_area_id: params[:leading][:work_area_id])
						end
					end
					if params[:leading][:occupation_id] == ""
					else
						if params[:leading][:occupation_id] == "-1"
							if params[:occupation_other] == nil
							else
								occupation = Occupation.new
								occupation.description = params[:occupation_other]
								occupation.organisation_id = current_personnel.organisation_id
								occupation.save
								@lead.update(occupation_id: occupation.id)
							end
						else
							@lead.update(occupation_id: params[:leading][:occupation_id])
						end
					end
					if current_personnel.organisation_id == 6
					else
						if params[:whatsapp_template_ids] == nil
						else
							params[:whatsapp_template_ids].each do |whatsapp_template_id|
								whatsapp_template = WhatsappTemplate.find(whatsapp_template_id.to_i)
								if (whatsapp_template.file_name == nil || whatsapp_template.file_name == '') && (whatsapp_template.file_url == nil || whatsapp_template.file_url == '')
									urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            result = HTTParty.post(urlstring,
						               :body => { :to_number => '+91'+@lead.mobile.to_s,
						                 :message => whatsapp_template.body,    
						                  :type => "text"
						                  }.to_json,
						                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
						            
						            template_send = TemplateSend.new
									template_send.template = whatsapp_template.title+' sent in Whatsapp'
									template_send.lead_id = @lead.id
									template_send.save	            
						            sleep(5)
						        else
						        	urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            result = HTTParty.post(urlstring,
						               :body => { :to_number => '+91'+@lead.mobile.to_s,
						                 :message => whatsapp_template.file_url,    
						                  :text => "",
						                  :type => "media"
						                  }.to_json,
						                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
						            template_send = TemplateSend.new
									template_send.template = whatsapp_template.title+' sent in Whatsapp'
									template_send.lead_id = @lead.id
									template_send.save	            
						            sleep(5)
						        end
							end
						end
						if params[:email_template_ids] == nil
						else
							params[:email_template_ids].each do |email_template_id|
								email_template = EmailTemplate.find(email_template_id.to_i)
								email_data=[email_template.id, current_personnel.id, @lead.id]
								# UserMailer.email_template_send(email_data).deliver
								template_send = TemplateSend.new
								template_send.template = email_template.title+' sent in Whatsapp'
								template_send.lead_id = @lead.id
								template_send.save	            
							end
						end
					end
					if params[:leading][:dob] == ""
					else
						@lead.update(dob: params[:leading][:dob])
					end
					@lead.update(escalated: nil, reengaged_on: nil)
					@lead.update(anticipation: params[:anticipation])
					if @lead.follow_ups!=[]
						@lead.follow_ups.each{|x| x.update(last: nil)}
						@followup.scheduled_time=@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
					else
						@followup.first=true	
					end
					@followup.last=true
					@followup.save
					if current_personnel.organisation_id == 1
						if @followup.telephony_call_id == nil
							data = [@followup.id, params[:telephony_call_id]]
							UserMailer.missed_telephony_call(data).deliver
						end
					end
					if repeat_site_visit != nil
						repeat_site_visit.update(follow_up_id: @followup.id)
					end
					if field_visit != nil
						field_visit.update(follow_up_id: @followup.id)
					end
					if params[:call_record_id]!=nil
						CallRecord.find(params[:call_record_id].to_i).update(follow_up_id: @followup.id)
					end
					if rescheduled_leads == 0
					else
						data = [rescheduled_leads, current_personnel.business_unit_id, current_personnel.id]
						UserMailer.lead_transferring(data).deliver
					end
					if transferred_leads == 0
					else
						data = [transferred_leads, current_personnel.business_unit_id, current_personnel.id]
						UserMailer.lead_transferring(data).deliver
					end
					# 
				end
			end
		elsif params[:sms_followup]=='SMS Followup'
			lead_id = params[:leading_id].to_i
			sms_followup=SmsFollowup.new
			sms_followup.lead_id=lead_id
			sms_followup.save
			@picked_lead=Lead.find(lead_id)
			if @picked_lead.business_unit.walkthrough==nil || @picked_lead.business_unit.walkthrough==''
				number='91'+@picked_lead.mobile
				number=number.to_s
		  		text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
		  		text=text.to_s
		  	else
				number='91'+@picked_lead.mobile
				number=number.to_s
				number='91'+@picked_lead.mobile
		  		text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
		  		text=text.to_s		  		
			end
	  		if @picked_lead.personnel.organisation.whatsapp_instance==nil
		  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
				response=HTTParty.get(urlstring)
			else
				if current_personnel.organisation_id == 6
					urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
					response=HTTParty.get(urlstring)
				end
				urlstring =  "https://eu71.chat-api.com/instance"+(@picked_lead.personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(@picked_lead.personnel.organisation.whatsapp_key)
				  		result = HTTParty.get(urlstring,
						   :body => { :phone => "91"+(@picked_lead.mobile),
						              :body => text.gsub("%0a","\n") 
						              }.to_json,
						   :headers => { 'Content-Type' => 'application/json' } )
			end
		elsif params[:email_followup] == 'Email Followup'
			lead_id = params[:leading_id].to_i
			if Lead.find(lead_id).email == nil || Lead.find(lead_id).email == ''
			else
				email_followup=EmailFollowup.new
				email_followup.lead_id=lead_id
				email_followup.save
				data=Lead.find(lead_id)
				UserMailer.email_followup_to_lead(data).deliver
			end
		end
		if params[:cost_sheet] == 'Cost Sheet'
			lead_id = params[:leading_id].to_i
			redirect_to action: :cost_sheet, lead_id: lead_id
		else
			if current_personnel.business_unit.organisation_id == 1
				if false_entry == true
					redirect_to :controller => "windows", :action => "followup_update", params: request.request_parameters
				else
					redirect_to windows_followup_due_url
				end
			else
				redirect_to :back
			end
		end
	else
		if params[:update] =='Update'
			common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
			rescheduled_leads = 0
			transferred_leads = 0
			data = []
			Lead.transaction do
				@followup = FollowUp.new
				@followup.lead_id = params[:leading_id].to_i
				@lead = Lead.find(@followup.lead_id)
				if current_personnel.business_unit.organisation_id == 1
					if params[:followups] == [] || params[:followups] == nil
						if params[:whatsapp_templates] == [] ||  params[:whatsapp_templates] == nil
							if params[:email_tempaltes] == [] || params[:email_tempaltes] == nil
							else
								params[:email_templates].each do |email_template_id|
									email_template = EmailTemplate.find(email_template_id)
									email_data = [email_template.id, current_personnel.id, @lead.id]
									# UserMailer.email_template_send(email_data).deliver

									template_send = TemplateSend.new
									template_send.template = email_template.title+' sent in Whatsapp'
									template_send.lead_id = @lead.id
									template_send.save
								end
							end
						else
							if params[:email_tempaltes] == [] || params[:email_tempaltes] == nil
								params[:whatsapp_templates].each do |whatsapp_template_id|
									whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
									if (whatsapp_template.file_name == nil || whatsapp_template.file_name == '') && (whatsapp_template.file_url == nil || whatsapp_template.file_url == '')
										urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(@lead.mobile),
							                 :message => whatsapp_template.body,    
							                  :type => "text"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							        	sleep(3)
							            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(current_personnel.mobile),
							                 :message => whatsapp_template.title+' sent to '+@lead.name,    
							                  :type => "text"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            sleep(3)
										template_send = TemplateSend.new
										template_send.template = whatsapp_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead.id
										template_send.save
									else
										urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(@lead.mobile),
							                 :message => whatsapp_template.file_url,    
							                  :text => "",
							                  :type => "media"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            sleep(3)
							            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(current_personnel.mobile),
							                 :message => whatsapp_template.title+' sent to '+@lead.name,    
							                  :type => "text"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            sleep(3)
										template_send = TemplateSend.new
										template_send.template = whatsapp_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead.id
										template_send.save
									end
									sleep(3)
								end
							else
								params[:email_templates].each do |email_template_id|
									email_template = EmailTemplate.find(email_template_id)
									email_data = [email_template.id, current_personnel.id, @lead.id]
									# UserMailer.email_template_send(email_data).deliver

									template_send = TemplateSend.new
									template_send.template = email_template.title+' sent in Whatsapp'
									template_send.lead_id = @lead.id
									template_send.save
								end
								params[:whatsapp_templates].each do |whatsapp_template_id|
									whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
									if (whatsapp_template.file_name == nil || whatsapp_template.file_name == '') && (whatsapp_template.file_url == nil || whatsapp_template.file_url == '')
										urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(@lead.mobile),
							                 :message => whatsapp_template.body,    
							                  :type => "text"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							        	sleep(3)
							            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(current_personnel.mobile),
							                 :message => whatsapp_template.title+' sent to '+@lead.name,    
							                  :type => "text"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            sleep(3)
										template_send = TemplateSend.new
										template_send.template = whatsapp_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead.id
										template_send.save
									else
										urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(@lead.mobile),
							                 :message => whatsapp_template.file_url,    
							                  :text => "",
							                  :type => "media"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            sleep(3)
							            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+(current_personnel.mobile),
							                 :message => whatsapp_template.title+' sent to '+@lead.name,    
							                  :type => "text"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            sleep(3)
										template_send = TemplateSend.new
										template_send.template = whatsapp_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead.id
										template_send.save
									end
									sleep(3)
								end
							end
						end
					else
						params[:followups].each do |followup_type|
							if followup_type == "Sms Followup"
								sms_followup = SmsFollowup.new
								sms_followup.lead_id = @lead.id
								sms_followup.save
								@picked_lead=@lead
								if @picked_lead.business_unit.walkthrough==nil || @picked_lead.business_unit.walkthrough==''
									number='91'+@picked_lead.mobile
									text = "Thanks for your enquiry at "+(@picked_lead.business_unit.name)+" !! We tried calling you but could not reach you. Please let me know a good time to call you. Regards, Contact Details: "+(@picked_lead.personnel.name) + "-" + (@picked_lead.personnel.mobile) +", DGHLPR"
			  					else
									number='91'+@picked_lead.mobile
							  		text = "Thanks for your enquiry at "+(@picked_lead.business_unit.name)+" !! We tried calling you but could not reach you. Please let me know a good time to call you. Regards, Contact Details: "+(@picked_lead.personnel.name) + "-" + (@picked_lead.personnel.mobile) +", DGHLPR"
								end
		  						# if @picked_lead.personnel.organisation.whatsapp_instance == nil
						  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=DGHLPR&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=06&peid=1701160498849382833&DLTTemplateId=1707168199126192644"
								response=HTTParty.get(urlstring)
								# end
							end
							if followup_type == "Email Followup"
								if @lead.email == nil || @lead.email == ''
								else
									email_followup = EmailFollowup.new
									email_followup.lead_id = @lead.id
									email_followup.save
									data = @lead
									UserMailer.email_followup_to_lead(data).deliver
								end
							end
						end
					end
					if common_followup_remarks.include?(params[:remarks]) == true
					else
						if @lead.business_unit.name=='Dream One' || @lead.business_unit.name=='Dream One Hotel Apartment'
					    	cli_number = "+918035469961"
					    elsif @lead.business_unit.name=='Dream Eco City'
					    	cli_number = "+918035469962"
					    elsif @lead.business_unit.name=='Dream Valley'
					    	cli_number = "+918035469963"
					    elsif @lead.business_unit.name=='Ecocity Bungalows'
					    	cli_number = "+918035469964"
					    else
					    	cli_number = "+918035469965"    
					    end
					    text = "Thank you for taking the time to speak with us. Your time is valuable, and we are grateful for your attention. Do reach out to us if you have any further questions or concerns. Thank you once again. Best Regards, "+@lead.personnel.name+"-"+cli_number.to_s+" DGHLPR"
					    if @lead.mobile == nil || @lead.mobile == ""
					    else
						    urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=DGHLPR&channel=Trans&DCS=0&flashsms=0' + "&number=" +(@lead.mobile.to_s)+ "&text=" + text + "&route=06&peid=1701160498849382833&DLTTemplateId=1707168605824430121"
							response = HTTParty.get(urlstring)
						end
					end
					if params[:extra_whatsapp_message] == nil
					else
						whatsapp_message = params[:extra_whatsapp_message]
						whatsapp_followup = WhatsappFollowup.new
						whatsapp_followup.lead_id = @lead.id
						whatsapp_followup.template_message = params[:extra_whatsapp_message]
						whatsapp_followup.save
						
						urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
			            result = HTTParty.post(urlstring,
			               :body => { :to_number => '+91'+(@lead.mobile),
			                 :message => whatsapp_message,    
			                  :type => "text"
			                  }.to_json,
			                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
					end	
				end
				if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Sales Executive' || current_personnel.status == "Audit"
					if @lead.status == true
						Lead.find(params[:leading_id].to_i).update(personnel_id: params[:leading][:personnel].to_i)
						@followup.personnel_id = current_personnel.id
					else	
						@followup.personnel_id = current_personnel.id
						Lead.find(params[:leading_id].to_i).update(personnel_id: params[:leading][:personnel].to_i)
					end
				else
					@followup.personnel_id=current_personnel.id
				end
				@followup.communication_time=params[:leading][:flexible_date]
				@followup.follow_up_time=params[:leading][:followup_date]
				followup_hours=params[:leading]['followup_time(4i)'].to_i*60*60
				followup_minutes=params[:leading]['followup_time(5i)'].to_i*60
				@followup.follow_up_time=@followup.follow_up_time+followup_hours+followup_minutes
				@followup.remarks=params[:remarks]
				if current_personnel.business_unit.organisation_id == 1
					if params[:telephony_call_id] == nil || params[:telephony_call_id] == ""
						telephony_call = TelephonyCall.where(lead_id: @lead.id, untagged: true).sort_by{|x| x.created_at}.last
						if telephony_call == nil
						else
							@followup.telephony_call_id = telephony_call.id
						end
					else
						@followup.telephony_call_id = params[:telephony_call_id].to_i
					end
				end
				if params[:site_visit_feedback] == nil
				else
					@followup.feedback = params[:site_visit_feedback]
				end
				if params[:remarks] == "Lead Rescheduled"
					rescheduled_leads += 1
				elsif params[:remarks] == "Lead transferred"
					transferred_leads += 1
				end
				if params[:leading][:status]=='0'
					@lead.update(status: nil, osv: nil, lost_reason_id: nil, booked_on: nil)
					@followup.osv=nil
					@followup.status=nil	
				elsif params[:leading][:status]=='1'
					@followup.osv = true
					@followup.status = nil
					if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
						@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
						
					elsif @lead.qualified_on == nil
						@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date])
						
					elsif @lead.interested_in_site_visit_on == nil
						@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil, interested_in_site_visit_on: params[:leading][:flexible_date])
					else
						@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil)
					end	
					@number='91'+@lead.mobile
					@number=@number.to_s
					if @lead.mobile == nil || @lead.mobile == ''
					else
						# if @lead.business_unit.organisation.sender_id=='LABULB'
						# 	@message="Thank you for interest in " + @lead.business_unit.name+ ", shortly our team will provide a demo of our services" + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
						# else
						# 	@message="Thank you for interest in " + @lead.business_unit.name + " !! Click the following link to download QR Code required for Site Visit and oblige.%0a%0a"+ (Bitly.client.shorten('http://www.realtybucket.com/windows/download_site_visit_qr_code?lead_id='+(@lead.id.to_s)).short_url) +"%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
						# end
					end
					if @lead.visit_organised_on==nil
						@lead.update(visit_organised_on: Time.now)
						# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
						# response=HTTParty.get(urlstring)
					end	
					if @lead.business_unit_id == 2
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 5
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DEC Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 6
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DV Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 3
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DWC Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					end
				elsif params[:leading][:status]=='11'
					if @lead.virtually_visited_on != nil
					else
						@lead.update(virtually_visited_on: Time.now, booked_on: nil, lost_reason_id: nil)
					end
					@followup.status = false
					@followup.osv = nil
					if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
					elsif @lead.qualified_on == nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date])	
					elsif @lead.interested_in_site_visit_on == nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, interested_in_site_visit_on: params[:leading][:flexible_date])
					else
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
					end
				elsif params[:leading][:status]=='2'
					if @lead.site_visited_on != nil
					else
						@lead.update(site_visited_on: Time.now, booked_on: nil, lost_reason_id: nil)
						@number='91'+@lead.mobile
						@number=@number.to_s
						if @lead.business_unit.walkthrough != nil
							@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
						else
							if @lead.business_unit.organisation.sender_id=='LABULB'
								@message="Thank you for meeting with us, hope you liked our demo. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							else
								@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							end
						end
						@email_template=EmailTemplate.find_by(business_unit_id: @lead.business_unit_id, site_visited: true, inactive: nil)
						if @email_template != nil
							if @lead.email==nil || @lead.email==''
							else
								data=[@lead.email, @email_template.id, current_personnel.id]
								# UserMailer.testing_email_send(data).deliver      
							end
						end
						@message=@message.to_s
				  # 		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
						# response=HTTParty.get(urlstring)
					end
					@followup.status=false
					@followup.osv=nil
					if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date], interested_in_site_visit_on: params[:leading][:flexible_date])
						
					elsif @lead.qualified_on == nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, qualified_on: params[:leading][:flexible_date])
						
					elsif @lead.interested_in_site_visit_on == nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil, interested_in_site_visit_on: params[:leading][:flexible_date])
					else
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
					end
					if @lead.visit_organised_on==nil
						@lead.update(visit_organised_on: Time.now)
					end
					if @lead.business_unit_id == 2
						dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
						dlt_result = HTTParty.get(dlturlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DO Site visited&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 5
						dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
						dlt_result = HTTParty.get(dlturlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DEC Site Visited&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 6
						dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
						dlt_result = HTTParty.get(dlturlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DV Site Visited&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 3
						dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
						dlt_result = HTTParty.get(dlturlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DWC Site Visited&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=Customer Pending Feedback&mode=ADD"
						new_add_result = HTTParty.get(addurlstring)
					end
				elsif params[:leading][:status]=='3'
					@followup.osv=nil
					@followup.status=false
					@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
					repeat_site_visit=RepeatVisit.new
					repeat_site_visit.follow_up_id=@followup.id
					repeat_site_visit.date=params[:leading][:flexible_date]
					repeat_site_visit.save
				elsif params[:leading][:status]=='6'
					@followup.osv=false
					@followup.status=false
					@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
					field_visited=false
					@lead.follow_ups.each do |follow_up|
						if FieldVisit.find_by_follow_up_id(follow_up.id)!=nil
							field_visited=true
						end
					end
					if field_visited==false
					field_visit=FieldVisit.new
					field_visit.follow_up_id=@followup.id
					field_visit.date=params[:leading][:flexible_date]
					field_visit.save
					end
				elsif params[:leading][:status]=='7'
					@followup.osv=false
					@followup.status=false
					@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
					field_visit=FieldVisit.new
					field_visit.follow_up_id=@followup.id
					field_visit.date=params[:leading][:flexible_date]
					field_visit.save
				elsif params[:leading][:status]=='8'
					@followup.osv=false
					@followup.status=nil
					@lead.update(status: nil, osv: false, lost_reason_id: nil, booked_on: nil)
				elsif params[:leading][:status]=='5'	
					@followup.status = true
					@followup.osv = nil
					@lead.update(status: true, osv: nil)
					@lead.update(booked_on: params[:leading][:flexible_date])
					@lead.update(lost_reason_id: params[:leading][:lost_reason])
					dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&mode=DELETE"
					dlt_result = HTTParty.get(dlturlstring)
				elsif params[:leading][:status]=='4'	
					@followup.status=true
					@followup.osv=nil
					@lead.update(status: true, osv: nil, lost_reason_id: nil)
					@lead.update(booked_on: params[:leading][:flexible_date])
				elsif params[:leading][:status]=='9'
					@followup.status = false
					@followup.osv = true
					if @lead.qualified_on==nil
						@lead.update(osv: true, status: false, qualified_on: Time.now, booked_on: nil, lost_reason_id: nil)
						
					else
						@lead.update(osv: true, status: false, booked_on: nil, lost_reason_id: nil)	
					end
					if @lead.business_unit_id == 2
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 5
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DEC Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 6
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DV Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 3
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DWC Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					end
				elsif params[:leading][:status]=='10'
					@followup.status = false
					@followup.osv = true
					if @lead.interested_in_site_visit_on==nil
						if @lead.qualified_on == nil
							@lead.update(osv: true, status: false, qualified_on: Time.now, interested_in_site_visit_on: Time.now, booked_on: nil, lost_reason_id: nil)
							
						else
							@lead.update(osv: true, status: false, interested_in_site_visit_on: Time.now, booked_on: nil, lost_reason_id: nil)
						end
					else
						@lead.update(osv: true, status: false, booked_on: nil, lost_reason_id: nil)
					end
					if @lead.business_unit_id == 2
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 5
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=DEC Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 6
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DV Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)
					elsif @lead.business_unit_id == 3
						addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead.mobile.to_s+"&email="+@lead.email.to_s+"&name="+@lead.name.to_s+"&tag=	DWC Qualified&mode=ADD"
						add_result = HTTParty.get(addurlstring)					
					end
				end
				if params[:leading][:area_id] == ""
				else
					if params[:leading][:area_id] == "-1"
						if params[:area_other] == nil
						else
							area = Area.new
							area.name = params[:area_other]
							area.organisation_id = current_personnel.organisation_id
							area.save
							@lead.update(area_id: area.id)
						end	
					else
						@lead.update(area_id: params[:leading][:area_id])
					end
				end
				if params[:leading][:age_bracket] == ""
				else
					@lead.update(age_bracket: params[:leading][:age_bracket])
				end
				if params[:leading][:work_area_id] == ""
				else
					if params[:leading][:work_area_id] == "-1"
						if params[:work_area_other] == nil
						else
							area = Area.new
							area.name = params[:work_area_other]
							area.organisation_id = current_personnel.organisation_id
							area.save
							@lead.update(work_area_id: area.id)
						end	
					else
						@lead.update(work_area_id: params[:leading][:work_area_id])
					end
				end
				if params[:leading][:occupation_id] == ""
				else
					if params[:leading][:occupation_id] == "-1"
						if params[:occupation_other] == nil
						else
							occupation = Occupation.new
							occupation.description = params[:occupation_other]
							occupation.organisation_id = current_personnel.organisation_id
							occupation.save
							@lead.update(occupation_id: occupation.id)
						end
					else
						@lead.update(occupation_id: params[:leading][:occupation_id])
					end
				end
				if current_personnel.organisation_id == 6
				else
					if params[:whatsapp_template_ids] == nil
					else
						params[:whatsapp_template_ids].each do |whatsapp_template_id|
							whatsapp_template = WhatsappTemplate.find(whatsapp_template_id.to_i)
							if (whatsapp_template.file_name == nil || whatsapp_template.file_name == '') && (whatsapp_template.file_url == nil || whatsapp_template.file_url == '')
								urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
					            result = HTTParty.post(urlstring,
					               :body => { :to_number => '+91'+@lead.mobile.to_s,
					                 :message => whatsapp_template.body,    
					                  :type => "text"
					                  }.to_json,
					                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
					            
					            template_send = TemplateSend.new
								template_send.template = whatsapp_template.title+' sent in Whatsapp'
								template_send.lead_id = @lead.id
								template_send.save	            
					            sleep(5)
					        else
					        	urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
					            result = HTTParty.post(urlstring,
					               :body => { :to_number => '+91'+@lead.mobile.to_s,
					                 :message => whatsapp_template.file_url,    
					                  :text => "",
					                  :type => "media"
					                  }.to_json,
					                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
					            template_send = TemplateSend.new
								template_send.template = whatsapp_template.title+' sent in Whatsapp'
								template_send.lead_id = @lead.id
								template_send.save	            
					            sleep(5)
					        end
						end
					end
					if params[:email_template_ids] == nil
					else
						params[:email_template_ids].each do |email_template_id|
							email_template = EmailTemplate.find(email_template_id.to_i)
							email_data=[email_template.id, current_personnel.id, @lead.id]
							# UserMailer.email_template_send(email_data).deliver
							template_send = TemplateSend.new
							template_send.template = email_template.title+' sent in Whatsapp'
							template_send.lead_id = @lead.id
							template_send.save	            
						end
					end
				end
				if params[:leading][:dob] == ""
				else
					@lead.update(dob: params[:leading][:dob])
				end
				@lead.update(escalated: nil, reengaged_on: nil)
				@lead.update(anticipation: params[:anticipation])
				if @lead.follow_ups!=[]
					@lead.follow_ups.each{|x| x.update(last: nil)}
					@followup.scheduled_time=@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
				else
					@followup.first=true	
				end
				@followup.last=true
				@followup.save
				if current_personnel.organisation_id == 1
					if @followup.telephony_call_id == nil
						data = [@followup.id, params[:telephony_call_id]]
						UserMailer.missed_telephony_call(data).deliver
					end
				end
				if repeat_site_visit != nil
					repeat_site_visit.update(follow_up_id: @followup.id)
				end
				if field_visit != nil
					field_visit.update(follow_up_id: @followup.id)
				end
				if params[:call_record_id]!=nil
					CallRecord.find(params[:call_record_id].to_i).update(follow_up_id: @followup.id)
				end
				if rescheduled_leads == 0
				else
					data = [rescheduled_leads, current_personnel.business_unit_id, current_personnel.id]
					UserMailer.lead_transferring(data).deliver
				end
				if transferred_leads == 0
				else
					data = [transferred_leads, current_personnel.business_unit_id, current_personnel.id]
					UserMailer.lead_transferring(data).deliver
				end
				# 
			end
		elsif params[:sms_followup]=='SMS Followup'
			lead_id = params[:leading_id].to_i
			sms_followup=SmsFollowup.new
			sms_followup.lead_id=lead_id
			sms_followup.save
			@picked_lead=Lead.find(lead_id)
			if @picked_lead.business_unit.walkthrough==nil || @picked_lead.business_unit.walkthrough==''
				number='91'+@picked_lead.mobile
				number=number.to_s
		  		text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
		  		text=text.to_s
		  	else
				number='91'+@picked_lead.mobile
				number=number.to_s
				number='91'+@picked_lead.mobile
		  		text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
		  		text=text.to_s		  		
			end
	  		if @picked_lead.personnel.organisation.whatsapp_instance==nil
		  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
				response=HTTParty.get(urlstring)
			else
				if current_personnel.organisation_id == 6
					urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
					response=HTTParty.get(urlstring)
				end
				urlstring =  "https://eu71.chat-api.com/instance"+(@picked_lead.personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(@picked_lead.personnel.organisation.whatsapp_key)
				  		result = HTTParty.get(urlstring,
						   :body => { :phone => "91"+(@picked_lead.mobile),
						              :body => text.gsub("%0a","\n") 
						              }.to_json,
						   :headers => { 'Content-Type' => 'application/json' } )
			end
		elsif params[:email_followup] == 'Email Followup'
			lead_id = params[:leading_id].to_i
			if Lead.find(lead_id).email == nil || Lead.find(lead_id).email == ''
			else
				email_followup=EmailFollowup.new
				email_followup.lead_id=lead_id
				email_followup.save
				data=Lead.find(lead_id)
				UserMailer.email_followup_to_lead(data).deliver
			end
		end
		if params[:cost_sheet] == 'Cost Sheet'
			lead_id = params[:leading_id].to_i
			redirect_to action: :cost_sheet, lead_id: lead_id
		else
			if current_personnel.business_unit.organisation_id == 1
				redirect_to windows_followup_due_url
			else
				redirect_to :back	
			end
		end
	end
end

def followup_update
	executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
	@executives=[]
	executives.each do |executive|
		@executives+=[[executive.name, executive.id]]
	end
	@executives.sort!
	@lead = Lead.find(params[:leading_id].to_i)
	@age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
	@areas = selections_with_other(Area, :name).sort
	@occupations=selections_with_other(Occupation, :description).sort
	@telephony_call_id = params[:telephony_call_id]
	@lost_reasons=selections(LostReason, :description)	
	@common_templates=[]
	@whatsapp_templates=[]
	@email_templates=[]
	@sms_templates=[]
	@common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred", "Called many time but the customer didn't respond", "Called many time but not reachable", "Call Forwarded"]
	if @lead.follow_ups==[] && @lead.whatsapps==[]
		flash[:danger]='no followup history present'
		redirect_to :back
	else
		WhatsappTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |whatsapp_template|
	      @whatsapp_templates+=[[whatsapp_template.title, whatsapp_template.id]]
	    end
	    EmailTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |email_template|
	      @email_templates+=[[email_template.title, email_template.id]]
	    end
	end
end

def field_visit_register
	if params.select{|key, value| value == ">" }.keys[0] == nil
		@projects=selections_with_all(BusinessUnit, :name)
		if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			if params[:project][:selected]=='-1'
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
			project_selected=params[:project][:selected]
			end
		end
		if params[:range]==nil
		@from=(Date.today)-60
		@to=(Date.today)+1
		else
		@from=params[:range][:from]
		@to=params[:range][:to]
		end
	
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
			@sales_team=site_executives=selections_with_all_active(Personnel, :name)
			if params[:refresh]=='Refresh'
			   @sales_person=params[:salesteam][:personnel].to_i
		    else
			   @sales_person=-1
			end
			if @sales_person==-1
			@field_visits=FieldVisit.includes(:follow_up => [:lead =>[:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('field_visits.date >= ? AND field_visits.date <= ?', @from, @to)
			else
			@field_visits=FieldVisit.includes(:follow_up => [:lead]).where(:leads => {business_unit_id: project_selected, personnel_id: @sales_person}).where('field_visits.date >= ? AND field_visits.date <= ?', @from, @to)
			end
		elsif current_personnel.status=='Team Lead'
		team_members=current_personnel.member_array	
		@field_visits=FieldVisit.includes(:follow_up => [:lead]).where(:leads => {business_unit_id: project_selected, personnel_id: team_members}).where('field_visits.date >= ? AND field_visits.date <= ?', @from, @to)
		else
		@field_visits=FieldVisit.includes(:follow_up => [:lead]).where(:leads => {business_unit_id: project_selected, personnel_id: current_personnel.id}).where('field_visits.date >= ? AND field_visits.date <= ?', @from, @to)
		end
	else
	redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
	end
end

def repeat_site_visit_register
	if params.select{|key, value| value == ">" }.keys[0] == nil
		@projects=selections_with_all(BusinessUnit, :name)
		if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		else
			if params[:project][:selected]=='-1'
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			else
			project_selected=params[:project][:selected]
			end
		end
		if params[:range]==nil
		@from=(Date.today)-60
		@to=(Date.today)+1
		else
		@from=params[:range][:from]
		@to=params[:range][:to]
		end
	
		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing'
			@sales_team=site_executives=selections_with_all_active(Personnel, :name)
			if params[:refresh]=='Refresh'
			   @sales_person=params[:salesteam][:personnel].to_i
		    else
			   @sales_person=-1
			end
			if @sales_person==-1
			@repeat_visits=RepeatVisit.includes(:follow_up => [:lead =>[:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id}, :leads => {business_unit_id: project_selected}).where('repeat_visits.date >= ? AND repeat_visits.date <= ?', @from, @to)
			else
			@repeat_visits=RepeatVisit.includes(:follow_up => [:lead]).where(:leads => {business_unit_id: project_selected, personnel_id: @sales_person}).where('repeat_visits.date >= ? AND repeat_visits.date <= ?', @from, @to)
			end
		elsif current_personnel.status=='Team Lead'
		team_members=current_personnel.member_array	
		@repeat_visits=RepeatVisit.includes(:follow_up => [:lead]).where(:leads => {business_unit_id: project_selected, personnel_id: team_members}).where('repeat_visits.date >= ? AND repeat_visits.date <= ?', @from, @to)
		else
		@repeat_visits=RepeatVisit.includes(:follow_up => [:lead]).where(:leads => {business_unit_id: project_selected, personnel_id: current_personnel.id}).where('repeat_visits.date >= ? AND repeat_visits.date <= ?', @from, @to)
		end
	else
	redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
	end
end

def call_record_follow_up_entry
	if params[:update] =='Update' 
			Lead.transaction do
				@followup=FollowUp.new
				@followup.lead_id=params[:leading_id].to_i
				@lead=Lead.find(@followup.lead_id)
				if @lead.personnel.status=='Admin' || @lead.personnel.status=='Back Office' || @lead.personnel.status=='Sales Executive'
					if @lead.status==true
					@followup.personnel_id=@lead.personnel_id
					else	
					@followup.personnel_id=params[:leading][:personnel].to_i
					Lead.find(params[:leading_id].to_i).update(personnel_id: @followup.personnel_id)
					end
				else
					@followup.personnel_id=@lead.personnel.id
				end
				@followup.communication_time=params[:leading][:flexible_date]
				@followup.follow_up_time=params[:leading][:followup_date]
				followup_hours=params[:leading]['followup_time(4i)'].to_i*60*60
				followup_minutes=params[:leading]['followup_time(5i)'].to_i*60
				@followup.follow_up_time=@followup.follow_up_time+followup_hours+followup_minutes
				@followup.remarks=params[:remarks]
				if params[:leading][:status]=='0'
					@lead.update(status: nil, osv: nil, lost_reason_id: nil, booked_on: nil)
					@followup.osv=nil
					@followup.status=nil	
				elsif params[:leading][:status]=='1'
					@followup.osv=true
					@followup.status=nil
					@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil)
				elsif params[:leading][:status]=='2'
					if @lead.site_visited_on != nil
					else
						@lead.update(site_visited_on: params[:leading][:flexible_date])
						@number='91'+@lead.mobile
						@number=@number.to_s
						if @lead.business_unit.walkthrough != nil
							@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
						else
							@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
						end
						@message=@message.to_s
				  # 		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
						# response=HTTParty.get(urlstring)
					end
					@followup.status=false
					@followup.osv=nil
					@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
				elsif params[:leading][:status]=='3'
					@followup.osv=nil
					@followup.status=false
					@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
					repeat_site_visit=RepeatVisit.new
					repeat_site_visit.follow_up_id=@followup.id
					repeat_site_visit.date=params[:leading][:flexible_date]
					repeat_site_visit.save
				elsif params[:leading][:status]=='6'
					@followup.osv=false
					@followup.status=false
					@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
					field_visited=false
					@lead.follow_ups.each do |follow_up|
						if FieldVisit.find_by_follow_up_id(follow_up.id)!=nil
							field_visited=true
						end
					end
					if field_visited==false
					field_visit=FieldVisit.new
					field_visit.follow_up_id=@followup.id
					field_visit.date=params[:leading][:flexible_date]
					field_visit.save
					end
				elsif params[:leading][:status]=='7'
					@followup.osv=false
					@followup.status=false
					@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
					field_visit=FieldVisit.new
					field_visit.follow_up_id=@followup.id
					field_visit.date=params[:leading][:flexible_date]
					field_visit.save
				elsif params[:leading][:status]=='8'
					@followup.osv=false
					@followup.status=nil
					@lead.update(status: nil, osv: false, lost_reason_id: nil, booked_on: nil)
				elsif params[:leading][:status]=='5'	
					@followup.status=true
					@followup.osv=nil
					@lead.update(status: true, osv: nil)
					@lead.update(booked_on: params[:leading][:flexible_date])
					@lead.update(lost_reason_id: params[:leading][:lost_reason])
				elsif params[:leading][:status]=='4'	
					@followup.status=true
					@followup.osv=nil
					@lead.update(status: true, osv: nil, lost_reason_id: nil)
					@lead.update(booked_on: params[:leading][:flexible_date])
				end
				@lead.update(escalated: nil)
				@lead.update(anticipation: params[:anticipation])
				if @lead.follow_ups!=[]
					@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.update(last: nil)
					@followup.scheduled_time=@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
				else
					@followup.first=true	
				end
				@followup.last=true
				@followup.save
				if repeat_site_visit != nil
				repeat_site_visit.update(follow_up_id: @followup.id)
				end
				if field_visit != nil
				field_visit.update(follow_up_id: @followup.id)
				end
				if params[:call_record_id]!=nil
					CallRecord.find(params[:call_record_id].to_i).update(follow_up_id: @followup.id)
				end
			end
		elsif params[:sms_followup]=='SMS Followup'
			lead_id = params[:leading_id].to_i
			sms_followup=SmsFollowup.new
			sms_followup.lead_id=lead_id
			sms_followup.save
			@picked_lead=Lead.find(lead_id)
			if @picked_lead.business_unit.walkthrough==nil
				number='91'+@picked_lead.mobile
				number=number.to_s
		  		text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
		  		text=text.to_s
		  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
				response=HTTParty.get(urlstring)
			else
				number='91'+@picked_lead.mobile
				number=number.to_s
				number='91'+@picked_lead.mobile
		  		text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
		  		text=text.to_s		  		
		  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
				response=HTTParty.get(urlstring)
			end
		elsif params[:email_followup] == 'Email Followup'
			lead_id = params[:leading_id].to_i
			if Lead.find(lead_id).email == nil || Lead.find(lead_id).email == ''
			else
				email_followup=EmailFollowup.new
				email_followup.lead_id=lead_id
				email_followup.save
				data=Lead.find(lead_id)
				UserMailer.email_followup_to_lead(data).deliver
			end
		
		else
		end
		flash[:info]='Followup entry updated!'
		redirect_to :action => "call_record_follow_up_entry_form", :call_record_id => params[:call_record_id]
end

def site_visit_entry_form
	if current_personnel==nil
	render :text => "Access Denied, kindly show QR Code at Project Site"
	else
	lead_id=params[:id]
	@lead=Lead.find(lead_id.to_i)
	@business_units=[]
	BusinessUnit.where(organisation_id: @lead.personnel.organisation_id).each do |business_unit|
		@business_units+=[[business_unit.name, business_unit.id]]
	end
	@site_executives=[]
	Personnel.where(organisation_id: @lead.personnel.organisation_id, access_right: nil).each do |site_executive|
		@site_executives+=[[site_executive.name, site_executive.id]]
	end
	end
    
end

def site_visit_entry
	@lead=Lead.find(params[:lead_id])
	@lead.update(business_unit_id: params[:lead][:business_unit_id].to_i)
	@lead.update(budget_from: params[:lead][:budget_from].to_i)
	@lead.update(budget_to: params[:lead][:budget_to].to_i)
	@lead.update(flat_type: params[:flat_type])
	@lead.update(name: params[:lead][:name])
	@lead.update(mobile: params[:lead][:mobile])
	@lead.update(other_number: params[:lead][:other_number])
	@lead.update(email: params[:lead][:email])
	@lead.update(address: params[:lead][:address])
	if @lead.source_category.heirarchy==params[:source]
	else
	source_changed=true
	end
	@lead.update(customer_remarks: params[:lead][:customer_remarks])

	@followup=FollowUp.new
	@followup.lead_id=@lead.id
	@followup.personnel_id=current_personnel.id
	@followup.communication_time=Time.now
	@followup.follow_up_time=Date.today+1.day+11.hours
	if source_changed==true
	@followup.remarks='Source changed by customer to '+params[:source]
	end
	if @lead.site_visited_on != nil
		@followup.osv=nil
		@followup.status=false
		@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
		repeat_site_visit=RepeatVisit.new
		repeat_site_visit.follow_up_id=@followup.id
		repeat_site_visit.date=Date.today
		repeat_site_visit.save
	else
		@lead.update(site_visited_on: Date.today)
		@followup.status=false
		@followup.osv=nil
		@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
	end
	if @lead.follow_ups!=[]
		@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.update(last: nil)
		@followup.scheduled_time=@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
	else
		@followup.first=true	
	end
	@followup.last=true
	@followup.save
	if repeat_site_visit != nil
	repeat_site_visit.update(follow_up_id: @followup.id)
	end
				
	flash[:info]="Thank you for visiting our site!"
	redirect_to :action => "site_visit_entry_form", :id => @lead.id
end

def direct_follow_up_entry_form
	if params[:id]!='direct_follow_up_entry_form'
	numeric_id=''
	mapping=['a','b','c','d','e','f','g','h','i','j']
	alpha_id=params[:id]
	alpha_ids=alpha_id.split("")
		alpha_ids.each do |alpha|
			numeric_id+=mapping.index(alpha).to_s
		end
	numeric_id=numeric_id.to_i	
	@lead=Lead.find(numeric_id)
	else
			if params[:update] =='Update'
				Lead.transaction do
					@followup=FollowUp.new
					@followup.lead_id=params[:leading_id].to_i
					@lead=Lead.find(@followup.lead_id)
					if @lead.personnel.status=='Admin' || @lead.personnel.status=='Back Office' || @lead.personnel.status=='Sales Executive'
						if @lead.status==true
						@followup.personnel_id=@lead.personnel_id
						else	
						@followup.personnel_id=params[:leading][:personnel].to_i
						Lead.find(params[:leading_id].to_i).update(personnel_id: @followup.personnel_id)
						end
					else
						@followup.personnel_id=@lead.personnel.id
					end
					@followup.communication_time=params[:leading][:flexible_date]
					@followup.follow_up_time=params[:leading][:followup_date]
					followup_hours=params[:leading]['followup_time(4i)'].to_i*60*60
					followup_minutes=params[:leading]['followup_time(5i)'].to_i*60
					@followup.follow_up_time=@followup.follow_up_time+followup_hours+followup_minutes
					@followup.remarks=params[:remarks]
					if params[:leading][:status]=='0'
						@lead.update(status: nil, osv: nil, lost_reason_id: nil, booked_on: nil)
						@followup.osv=nil
						@followup.status=nil	
					elsif params[:leading][:status]=='1'
						@followup.osv=true
						@followup.status=nil
						@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil)
					elsif params[:leading][:status]=='2'
						if @lead.site_visited_on != nil
						else
							@lead.update(site_visited_on: params[:leading][:flexible_date])
							@number='91'+@lead.mobile
							@number=@number.to_s
							if @lead.business_unit.walkthrough != nil
								@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							else
								@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							end
							@message=@message.to_s
					  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
							response=HTTParty.get(urlstring)
						end
						@followup.status=false
						@followup.osv=nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
					elsif params[:leading][:status]=='3'
						@followup.osv=nil
						@followup.status=false
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
						repeat_site_visit=RepeatVisit.new
						repeat_site_visit.follow_up_id=@followup.id
						repeat_site_visit.date=params[:leading][:flexible_date]
						repeat_site_visit.save
					elsif params[:leading][:status]=='6'
						@followup.osv=false
						@followup.status=false
						@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
						field_visited=false
						@lead.follow_ups.each do |follow_up|
							if FieldVisit.find_by_follow_up_id(follow_up.id)!=nil
								field_visited=true
							end
						end
						if field_visited==false
						field_visit=FieldVisit.new
						field_visit.follow_up_id=@followup.id
						field_visit.date=params[:leading][:flexible_date]
						field_visit.save
						end
					elsif params[:leading][:status]=='7'
						@followup.osv=false
						@followup.status=false
						@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
						field_visit=FieldVisit.new
						field_visit.follow_up_id=@followup.id
						field_visit.date=params[:leading][:flexible_date]
						field_visit.save
					elsif params[:leading][:status]=='8'
						@followup.osv=false
						@followup.status=nil
						@lead.update(status: nil, osv: false, lost_reason_id: nil, booked_on: nil)
					elsif params[:leading][:status]=='5'	
						@followup.status=true
						@followup.osv=nil
						@lead.update(status: true, osv: nil)
						@lead.update(booked_on: params[:leading][:flexible_date])
						@lead.update(lost_reason_id: params[:leading][:lost_reason])
					elsif params[:leading][:status]=='4'	
						@followup.status=true
						@followup.osv=nil
						@lead.update(status: true, osv: nil, lost_reason_id: nil)
						@lead.update(booked_on: params[:leading][:flexible_date])
					end
					@lead.update(escalated: nil)
					@lead.update(anticipation: params[:anticipation])
					if @lead.follow_ups!=[]
						@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.update(last: nil)
						@followup.scheduled_time=@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
					else
						@followup.first=true	
					end
					@followup.last=true
					@followup.save
					if repeat_site_visit != nil
					repeat_site_visit.update(follow_up_id: @followup.id)
					end
					if field_visit != nil
					field_visit.update(follow_up_id: @followup.id)
					end
					if params[:call_record_id]!=nil
						CallRecord.find(params[:call_record_id].to_i).update(follow_up_id: @followup.id)
					end
				end
				flash[:info]="Followup Entry Done!"
			elsif params[:sms_followup]=='SMS Followup'
				lead_id = params[:leading_id].to_i
				sms_followup=SmsFollowup.new
				sms_followup.lead_id=lead_id
				sms_followup.save
				@picked_lead=Lead.find(lead_id)
				@lead=@picked_lead
				if @picked_lead.business_unit.walkthrough==nil
					number='91'+@picked_lead.mobile
					number=number.to_s
			  		text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
			  		text=text.to_s
			  	else
					number='91'+@picked_lead.mobile
					number=number.to_s
					number='91'+@picked_lead.mobile
			  		text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
			  		text=text.to_s		  		
			  	end
		  		if @picked_lead.personnel.organisation.whatsapp_instance==nil
		  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
				response=HTTParty.get(urlstring)
				else
				urlstring =  "https://eu71.chat-api.com/instance"+(@picked_lead.personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(@picked_lead.personnel.organisation.whatsapp_key)
					  		result = HTTParty.get(urlstring,
							   :body => { :phone => "91"+(@picked_lead.mobile),
							              :body => text.gsub("%0a","\n") 
							              }.to_json,
							   :headers => { 'Content-Type' => 'application/json' } )
				end
			flash[:info]="SMS Sent!"	
			elsif params[:email_followup] == 'Email Followup'
				lead_id = params[:leading_id].to_i
				@lead=Lead.find(lead_id)
				if Lead.find(lead_id).email == nil || Lead.find(lead_id).email == ''
				else
					email_followup=EmailFollowup.new
					email_followup.lead_id=lead_id
					email_followup.save
					data=Lead.find(lead_id)
					UserMailer.email_followup_to_lead(data).deliver
				end
			flash[:info]="Email Sent!"
			else
			end

	end
	if @lead.personnel.status=='Admin' || @lead.personnel.status=='Back Office'	|| @lead.personnel.status=='Sales Executive' || @lead.personnel.status=='Team Lead'
		executives=Personnel.where(organisation_id: @lead.personnel.organisation_id).where('access_right is ? OR access_right = ?', nil, 2)
		@executives=[]
		executives.each do |executive|
			@executives+=[[executive.name, executive.id]]
		end
		@executives.sort!
	end
	@lost_reasons=[]
	LostReason.where(organisation_id: @lead.personnel.organisation_id).each do |lost_reason|
	@lost_reasons+=[[lost_reason.description, lost_reason.id]]
	end		
end

def call_record_follow_up_entry_form
	if params[:id]!='call_record_follow_up_entry'
	@call_record=CallRecord.find(params[:id])
	else
			if params[:update] =='Update' 
				Lead.transaction do
					@followup=FollowUp.new
					@followup.lead_id=params[:leading_id].to_i
					@lead=Lead.find(@followup.lead_id)
					if @lead.personnel.status=='Admin' || @lead.personnel.status=='Back Office' || @lead.personnel.status=='Sales Executive'
						if @lead.status==true
						@followup.personnel_id=@lead.personnel_id
						else	
						@followup.personnel_id=params[:leading][:personnel].to_i
						Lead.find(params[:leading_id].to_i).update(personnel_id: @followup.personnel_id)
						end
					else
						@followup.personnel_id=@lead.personnel.id
					end
					@followup.communication_time=params[:leading][:flexible_date]
					@followup.follow_up_time=params[:leading][:followup_date]
					followup_hours=params[:leading]['followup_time(4i)'].to_i*60*60
					followup_minutes=params[:leading]['followup_time(5i)'].to_i*60
					@followup.follow_up_time=@followup.follow_up_time+followup_hours+followup_minutes
					@followup.remarks=params[:remarks]
					if params[:leading][:status]=='0'
						@lead.update(status: nil, osv: nil, lost_reason_id: nil, booked_on: nil)
						@followup.osv=nil
						@followup.status=nil	
					elsif params[:leading][:status]=='1'
						@followup.osv=true
						@followup.status=nil
						@lead.update(osv: true, status: nil, lost_reason_id: nil, booked_on: nil)
					elsif params[:leading][:status]=='2'
						if @lead.site_visited_on != nil
						else
							@lead.update(site_visited_on: params[:leading][:flexible_date])
							@number='91'+@lead.mobile
							@number=@number.to_s
							if @lead.business_unit.walkthrough != nil
								@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							else
								@message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
							end
							@message=@message.to_s
					  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
							response=HTTParty.get(urlstring)
						end
						@followup.status=false
						@followup.osv=nil
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
					elsif params[:leading][:status]=='3'
						@followup.osv=nil
						@followup.status=false
						@lead.update(status: false, osv: nil, lost_reason_id: nil, booked_on: nil)
						repeat_site_visit=RepeatVisit.new
						repeat_site_visit.follow_up_id=@followup.id
						repeat_site_visit.date=params[:leading][:flexible_date]
						repeat_site_visit.save
					elsif params[:leading][:status]=='6'
						@followup.osv=false
						@followup.status=false
						@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
						field_visited=false
						@lead.follow_ups.each do |follow_up|
							if FieldVisit.find_by_follow_up_id(follow_up.id)!=nil
								field_visited=true
							end
						end
						if field_visited==false
						field_visit=FieldVisit.new
						field_visit.follow_up_id=@followup.id
						field_visit.date=params[:leading][:flexible_date]
						field_visit.save
						end
					elsif params[:leading][:status]=='7'
						@followup.osv=false
						@followup.status=false
						@lead.update(status: false, osv: false, lost_reason_id: nil, booked_on: nil)
						field_visit=FieldVisit.new
						field_visit.follow_up_id=@followup.id
						field_visit.date=params[:leading][:flexible_date]
						field_visit.save
					elsif params[:leading][:status]=='8'
						@followup.osv=false
						@followup.status=nil
						@lead.update(status: nil, osv: false, lost_reason_id: nil, booked_on: nil)
					elsif params[:leading][:status]=='5'	
						@followup.status=true
						@followup.osv=nil
						@lead.update(status: true, osv: nil)
						@lead.update(booked_on: params[:leading][:flexible_date])
						@lead.update(lost_reason_id: params[:leading][:lost_reason])
					elsif params[:leading][:status]=='4'	
						@followup.status=true
						@followup.osv=nil
						@lead.update(status: true, osv: nil, lost_reason_id: nil)
						@lead.update(booked_on: params[:leading][:flexible_date])
					end
					@lead.update(escalated: nil)
					@lead.update(anticipation: params[:anticipation])
					if @lead.follow_ups!=[]
						@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.update(last: nil)
						@followup.scheduled_time=@lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
					else
						@followup.first=true	
					end
					@followup.last=true
					@followup.save
					if repeat_site_visit != nil
					repeat_site_visit.update(follow_up_id: @followup.id)
					end
					if field_visit != nil
					field_visit.update(follow_up_id: @followup.id)
					end
					if params[:call_record_id]!=nil
						CallRecord.find(params[:call_record_id].to_i).update(follow_up_id: @followup.id)
					end
				end
			elsif params[:sms_followup]=='SMS Followup'
				lead_id = params[:leading_id].to_i
				sms_followup=SmsFollowup.new
				sms_followup.lead_id=lead_id
				sms_followup.save
				@picked_lead=Lead.find(lead_id)
				if @picked_lead.business_unit.walkthrough==nil
					number='91'+@picked_lead.mobile
					number=number.to_s
			  		text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
			  		text=text.to_s
			  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
					response=HTTParty.get(urlstring)
				else
					number='91'+@picked_lead.mobile
					number=number.to_s
					number='91'+@picked_lead.mobile
			  		text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
			  		text=text.to_s		  		
			  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
					response=HTTParty.get(urlstring)
				end
			elsif params[:email_followup] == 'Email Followup'
				lead_id = params[:leading_id].to_i
				if Lead.find(lead_id).email == nil || Lead.find(lead_id).email == ''
				else
					email_followup=EmailFollowup.new
					email_followup.lead_id=lead_id
					email_followup.save
					data=Lead.find(lead_id)
					UserMailer.email_followup_to_lead(data).deliver
				end
			
			else
			end

	@call_record=CallRecord.find(params[:call_record_id])	
	end
	@lead=@call_record.lead
	if @lead.personnel.status=='Admin' || @lead.personnel.status=='Back Office'	|| @lead.personnel.status=='Sales Executive' || @lead.personnel.status=='Team Lead'
		executives=Personnel.where(organisation_id: @lead.personnel.organisation_id).where('access_right is ? OR access_right = ?', nil, 2)
		@executives=[]
		executives.each do |executive|
			@executives+=[[executive.name, executive.id]]
		end
		@executives.sort!
	end
	@lost_reasons=[]
	LostReason.where(organisation_id: @lead.personnel.organisation_id).each do |lost_reason|
	@lost_reasons+=[[lost_reason.description, lost_reason.id]]
	end		
end

def fresh_lead_submit
	if params[:whatsapp]
		whatsapp_template = params[:whatsapp]
		@whatsapp_template = WhatsappTemplate.find_by_title(whatsapp_template.to_s)
		params[:lead_id].each do |lead_id|
			@lead = Lead.find(lead_id.to_i)
			urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(@lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(@lead.mobile))
	      	result = HTTParty.get(urlstring)
			if result.parsed_response['result'] != 'not exists'            
				# if @whatsapp_template.whatsapp_images==[]
					if (@whatsapp_template.file_name == nil || @whatsapp_template.file_name == '') && (@whatsapp_template.file_url == nil || @whatsapp_template.file_url == '')
						urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
			            result = HTTParty.post(urlstring,
			               :body => { :to_number => '+91'+(@lead.mobile),
			                 :message => @whatsapp_template.body,    
			                  :type => "text"
			                  }.to_json,
			                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
			            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
			            result = HTTParty.post(urlstring,
			               :body => { :to_number => '+91'+(current_personnel.mobile),
			                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
			                  :type => "text"
			                  }.to_json,
			                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

						template_send = TemplateSend.new
						template_send.template = @whatsapp_template.title+' sent in Whatsapp'
						template_send.lead_id = @lead.id
						template_send.save

						flash[:success]='Whatsapp send successfully.'	
					else
						urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
			            result = HTTParty.post(urlstring,
			               :body => { :to_number => '+91'+(@lead.mobile),
			                 :message => @whatsapp_template.file_url,    
			                  :text => "",
			                  :type => "media"
			                  }.to_json,
			                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
			            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
			            result = HTTParty.post(urlstring,
			               :body => { :to_number => '+91'+(current_personnel.mobile),
			                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
			                  :type => "text"
			                  }.to_json,
			                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

						template_send = TemplateSend.new
						template_send.template = @whatsapp_template.title+' sent in Whatsapp'
						template_send.lead_id = @lead.id
						template_send.save

						flash[:success]='Whatsapp send successfully.'
					end
				# else
					# urlstring =  "https://eu71.chat-api.com/instance"+@lead.business_unit.organisation.whatsapp_instance+"/sendFile?token="+@lead.business_unit.organisation.whatsapp_key
					#   result = HTTParty.get(urlstring,
					#   :body => { :phone => "91"+(@lead.mobile),
					#    :body => 'https:'+(@whatsapp_template.whatsapp_images[0].image.url),
					#              :caption => @whatsapp_template.body,
					#              :filename => @whatsapp_template.whatsapp_images[0].image_file_name
					#              }.to_json,
					#   :headers => { 'Content-Type' => 'application/json' } )	
		   #      	urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(@lead.personnel.organisation.whatsapp_key)
					#   result = HTTParty.get(urlstring,
					#   :body => { :phone => "91"+(current_personnel.mobile),
					#              :body => @whatsapp_template.title+' sent to '+@lead.name
					#              }.to_json,
					#   :headers => { 'Content-Type' => 'application/json' } )
					
					# template_send = TemplateSend.new
					# template_send.template = @whatsapp_template.title+' sent in Whatsapp'
					# template_send.lead_id = @lead.id
					# template_send.save
					
					# flash[:success]='Whatsapp send successfully.'
				# end
			else
				if @lead.other_number == nil || @lead.other_number == ''
		          flash[:danger]='Other Number is nil for this customer so whatsapp cannot be send'  
		        else
		          urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(@lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(@lead.other_number))
		          result = HTTParty.get(urlstring)
		            if result.parsed_response['result'] != 'not exists'
			          	# if @whatsapp_template.whatsapp_images==[]
			        		if (@whatsapp_template.file_name == nil || @whatsapp_template.file_name == '') && (@whatsapp_template.file_url == nil || @whatsapp_template.file_url == '')
								urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
					            result = HTTParty.post(urlstring,
					               :body => { :to_number => '+91'+(@lead.other_number),
					                 :message => @whatsapp_template.body,    
					                  :type => "text"
					                  }.to_json,
					                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
					            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
					            result = HTTParty.post(urlstring,
					               :body => { :to_number => '+91'+(current_personnel.mobile),
					                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
					                  :type => "text"
					                  }.to_json,
					                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

								template_send = TemplateSend.new
								template_send.template = @whatsapp_template.title+' sent in Whatsapp'
								template_send.lead_id = @lead.id
								template_send.save

								flash[:success]='Whatsapp send successfully.'	
							else
								urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
					            result = HTTParty.post(urlstring,
					               :body => { :to_number => '+91'+(@lead.other_number),
					                 :message => @whatsapp_template.file_url,    
					                  :text => "",
					                  :type => "media"
					                  }.to_json,
					                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
					            urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
					            result = HTTParty.post(urlstring,
					               :body => { :to_number => '+91'+(current_personnel.mobile),
					                 :message => @whatsapp_template.title+' sent to '+@lead.name,    
					                  :type => "text"
					                  }.to_json,
					                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )

								template_send = TemplateSend.new
								template_send.template = @whatsapp_template.title+' sent in Whatsapp'
								template_send.lead_id = @lead.id
								template_send.save

								flash[:success]='Whatsapp send successfully.'
							end
						# else
						# 	urlstring =  "https://eu71.chat-api.com/instance"+@lead.business_unit.organisation.whatsapp_instance+"/sendFile?token="+@lead.business_unit.organisation.whatsapp_key
						# 	  result = HTTParty.get(urlstring,
						# 	  :body => { :phone => "91"+(@lead.other_number),
						# 	   :body => 'https:'+(@whatsapp_template.whatsapp_images[0].image.url),
						# 	             :caption => @whatsapp_template.body,
						# 	             :filename => @whatsapp_template.whatsapp_images[0].image_file_name
						# 	             }.to_json,
						# 	  :headers => { 'Content-Type' => 'application/json' } )	
				  #       	urlstring =  "https://eu71.chat-api.com/instance"+(@lead.personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(@lead.personnel.organisation.whatsapp_key)
						# 	  result = HTTParty.get(urlstring,
						# 	  :body => { :phone => "91"+(current_personnel.mobile),
						# 	             :body => @whatsapp_template.title+' sent to '+@lead.name
						# 	             }.to_json,
						# 	  :headers => { 'Content-Type' => 'application/json' } )

						# 	template_send = TemplateSend.new
						# 	template_send.template = @whatsapp_template.title+' sent in Whatsapp'
						# 	template_send.lead_id = @lead.id
						# 	template_send.save  

						# 	flash[:success]='Whatsapp send successfully.'
						# end
					else
						flash[:danger]='Number not active on Whatsapp'  
		      	  	end
		      	end
			end  
		end

		redirect_to :back
	elsif params[:email]
		params[:lead_id].each do |lead_id|
			@lead=Lead.find(lead_id.to_i)
			email_template = params[:email]
			@email_template=EmailTemplate.find_by_title(email_template.to_s)
			email_data=[@email_template.id, current_personnel.id, @lead.id]
			# UserMailer.email_template_send(email_data).deliver
		end
		flash[:success]='Email sent successfully.'

		redirect_to :back
	else
		redirect_to controller: 'windows', action: 'followup_entry', params: request.request_parameters 
	end
end

def followup_entry
	if params.select{|key, value| value == ">" }.keys[0] == nil
		if params[:update] =='Update'
			common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
			rescheduled_leads = 0
			transferred_leads = 0
			data = []
			Lead.transaction do
				if current_personnel.status=='Back Office' || current_personnel.status=='Admin' || current_personnel.status == "Audit"
					all_leads = params[:lead_id]
					all_leads.each do |lead_id|
						@lead_picked = Lead.find(lead_id.to_i)
						if current_personnel.business_unit.organisation_id == 1
							if params[:followups] == [] || params[:followups] == nil
								if params[:whatsapp_templates] == [] ||  params[:whatsapp_templates] == nil
									if params[:email_tempaltes] == [] || params[:email_tempaltes] == nil
									else
										params[:email_templates].each do |email_template_id|
											email_template = EmailTemplate.find(email_template_id)
											email_data = [email_template.id, current_personnel.id, @lead_picked.id]
											# UserMailer.email_template_send(email_data).deliver

											template_send = TemplateSend.new
											template_send.template = email_template.title+' sent in Whatsapp'
											template_send.lead_id = @lead_picked.id
											template_send.save
										end
									end
								else
									if params[:email_tempaltes] == []  || params[:email_tempaltes] == nil
										if current_personnel.business_unit_id == 70
											params[:whatsapp_templates].each do |whatsapp_template_name|
												dg_pdfs = [["gurukul_brochure_mobileview", "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21751&authkey=!ALhDU300XRQYHLs&em=2"]]
												if whatsapp_template_name == "gurukul_brochure_mobileview"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
													if @lead_picked.other_number == nil || @lead_picked.other_number == ""
													else
														if @lead_picked.other_number.length == 10
															urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
															result = HTTParty.post(urlstring,
															:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.other_number.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
															:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
															p result
															p "============project details result===================="
															whatsapp_followup = WhatsappFollowup.new
															whatsapp_followup.lead_id = @lead_picked.id
															whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
															message_data = result.parsed_response
														  	message_id = message_data["messages"]
														  	message_id = message_id[0]["id"]
															whatsapp_followup.message_id = message_id
															whatsapp_followup.save
														end
													end
												elsif whatsapp_template_name == "gurukul_location" || whatsapp_template_name == "gurukul_project_brief"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => { "messaging_product": "whatsapp", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
													if @lead_picked.other_number == nil || @lead_picked.other_number == ""
													else
														if @lead_picked.other_number.length == 10
															urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
															result = HTTParty.post(urlstring,
															:body => { "messaging_product": "whatsapp", "to": "91"+@lead_picked.other_number.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
															:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
															p result
															p "============project details result===================="
															whatsapp_followup = WhatsappFollowup.new
															whatsapp_followup.lead_id = @lead_picked.id
															whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
															message_data = result.parsed_response
														  	message_id = message_data["messages"]
														  	message_id = message_id[0]["id"]
															whatsapp_followup.message_id = message_id
															whatsapp_followup.save
														end
													end
												end
											end
										else
											params[:whatsapp_templates].each do |whatsapp_template_id|
												whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
												if whatsapp_template.template_type == "pdf"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template.title, "link": whatsapp_template.file_url.to_s}}] } ]}}.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
												elsif whatsapp_template.template_type == "video"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url}}] } ]}}.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
												elsif whatsapp_template.template_type == "text"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => { "messaging_product": "whatsapp", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": { "name": whatsapp_template.title, "language": { "code": "en" } } }.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
												end
											end
										end
									else
										params[:email_templates].each do |email_template_id|
											email_template = EmailTemplate.find(email_template_id)
											email_data = [email_template.id, current_personnel.id, @lead_picked.id]
											# UserMailer.email_template_send(email_data).deliver

											template_send = TemplateSend.new
											template_send.template = email_template.title+' sent in Whatsapp'
											template_send.lead_id = @lead_picked.id
											template_send.save
										end
										if current_personnel.business_unit_id == 70
											params[:whatsapp_templates].each do |whatsapp_template_name|
												dg_pdfs = [["gurukul_brochure_mobileview", "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21751&authkey=!ALhDU300XRQYHLs&em=2"]]
												if whatsapp_template_name == "gurukul_brochure_mobileview"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
													if @lead_picked.other_number == nil || @lead_picked.other_number == ""
													else
														if @lead_picked.other_number.length == 10
															urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
															result = HTTParty.post(urlstring,
															:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.other_number.to_s, "type": "template", "template": {"name": whatsapp_template_name.to_s,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template_name.to_s, "link": dg_pdfs.find{|template_name, link| template_name == whatsapp_template_name}[1].to_s}}] } ]}}.to_json,
															:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
															p result
															p "============project details result===================="
															whatsapp_followup = WhatsappFollowup.new
															whatsapp_followup.lead_id = @lead_picked.id
															whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
															message_data = result.parsed_response
														  	message_id = message_data["messages"]
														  	message_id = message_id[0]["id"]
															whatsapp_followup.message_id = message_id
															whatsapp_followup.save
														end
													end
												elsif whatsapp_template_name == "gurukul_location" || whatsapp_template_name == "gurukul_project_brief"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => { "messaging_product": "whatsapp", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
													if @lead_picked.other_number == nil || @lead_picked.other_number == ""
													else
														if @lead_picked.other_number.length == 10
															urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
															result = HTTParty.post(urlstring,
															:body => { "messaging_product": "whatsapp", "to": "91"+@lead_picked.other_number.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
															:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
															p result
															p "============project details result===================="
															whatsapp_followup = WhatsappFollowup.new
															whatsapp_followup.lead_id = @lead_picked.id
															whatsapp_followup.template_message = whatsapp_template_name.to_s+" sent in whatsapp"
															message_data = result.parsed_response
														  	message_id = message_data["messages"]
														  	message_id = message_id[0]["id"]
															whatsapp_followup.message_id = message_id
															whatsapp_followup.save
														end
													end
												end
											end
										else
											params[:whatsapp_templates].each do |whatsapp_template_id|
												whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
												if whatsapp_template.template_type == "pdf"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "document","document": {"filename": whatsapp_template.title, "link": whatsapp_template.file_url.to_s}}] } ]}}.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
												elsif whatsapp_template.template_type == "video"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": {"name": whatsapp_template.title,"language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url}}] } ]}}.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
												elsif whatsapp_template.template_type == "text"
													urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
													result = HTTParty.post(urlstring,
													:body => { "messaging_product": "whatsapp", "to": "91"+@lead_picked.mobile.to_s, "type": "template", "template": { "name": whatsapp_template.title, "language": { "code": "en" } } }.to_json,
													:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
													p result
													p "============project details result===================="
													whatsapp_followup = WhatsappFollowup.new
													whatsapp_followup.lead_id = @lead_picked.id
													whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
													message_data = result.parsed_response
												  	message_id = message_data["messages"]
												  	message_id = message_id[0]["id"]
													whatsapp_followup.message_id = message_id
													whatsapp_followup.save
												end
											end
										end
									end
								end
							else
								params[:followups].each do |followup_type|
									if followup_type == "Sms Followup"
										sms_followup = SmsFollowup.new
										sms_followup.lead_id = @lead_picked.id
										sms_followup.save
										@picked_lead=@lead_picked
										if @picked_lead.business_unit.walkthrough==nil || @picked_lead.business_unit.walkthrough==''
											number='91'+@picked_lead.mobile
								  			text = "Thanks for your enquiry at "+(@picked_lead.business_unit.name)+" !! We tried calling you but could not reach you. Please let me know a good time to call you. Regards, Contact Details: "+(@picked_lead.personnel.name) + "-" + (@picked_lead.personnel.mobile) +", DGHLPR"
					  					else
											number='91'+@picked_lead.mobile
											text = "Thanks for your enquiry at "+(@picked_lead.business_unit.name)+" !! We tried calling you but could not reach you. Please let me know a good time to call you. Regards, Contact Details: "+(@picked_lead.personnel.name) + "-" + (@picked_lead.personnel.mobile) +", DGHLPR"
										end
				  						if @picked_lead.personnel.organisation.whatsapp_instance == nil
									  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=DGHLPR&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=06&peid=1701160498849382833&DLTTemplateId=1707168199126192644"
											response=HTTParty.get(urlstring)
										end
									end
									if followup_type == "Email Followup"
										if @lead_picked.email == nil || @lead_picked.email == ''
										else
											email_followup = EmailFollowup.new
											email_followup.lead_id = @lead_picked.id
											email_followup.save
											data = @lead_picked
											UserMailer.email_followup_to_lead(data).deliver
										end
									end
								end
							end
							if common_followup_remarks.include?(params[:remarks]) == true
							else
								if @lead_picked.business_unit.name=='Dream One' || @lead_picked.business_unit.name=='Dream One Hotel Apartment'
							    	cli_number = "+918035469961"
							    elsif @lead_picked.business_unit.name=='Dream Eco City'
							    	cli_number = "+918035469962"
							    elsif @lead_picked.business_unit.name=='Dream Valley'
							    	cli_number = "+918035469963"
							    elsif @lead_picked.business_unit.name=='Ecocity Bungalows'
							    	cli_number = "+918035469964"
							    else
							    	cli_number = "+918035469965"    
							    end
							    text = "Thank you for taking the time to speak with us. Your time is valuable, and we are grateful for your attention. Do reach out to us if you have any further questions or concerns. Thank you once again. Best Regards, "+@lead_picked.personnel.name+"-"+cli_number.to_s+" DGHLPR"
							    if @lead_picked.mobile == nil || @lead_picked.mobile == ""
							    else
								    urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=DGHLPR&channel=Trans&DCS=0&flashsms=0' + "&number=" +(@lead_picked.mobile.to_s)+ "&text=" + text + "&route=06&peid=1701160498849382833&DLTTemplateId=1707168605824430121"
									response = HTTParty.get(urlstring)
								end
							end
						end
						
						@followup = FollowUp.new
						@followup.personnel_id = current_personnel.id
						if params[:lead][:personnel] == nil || params[:lead][:personnel] == ""
						else
							@lead_picked.update(personnel_id: params[:lead][:personnel].to_i)
						end
						@followup.lead_id = lead_id
						@followup.communication_time = params[:lead][:flexible_date]
						@followup.follow_up_time = params[:lead][:followup_date]
						followup_hours = params[:lead]['followup_time(4i)'].to_i*60*60
						followup_minutes = params[:lead]['followup_time(5i)'].to_i*60
						@followup.follow_up_time = @followup.follow_up_time+followup_hours+followup_minutes
						@followup.remarks=params[:remarks]
						if current_personnel.business_unit.organisation_id == 1
							if params[:telephony_call_id] == nil || params[:telephony_call_id] == ""
								telephony_call = TelephonyCall.where(lead_id: @lead_picked.id, untagged: true).sort_by{|x| x.created_at}.last
								if telephony_call == nil
								else
									@followup.telephony_call_id = telephony_call.id
								end
							else
								@followup.telephony_call_id = params[:telephony_call_id].to_i
							end
						end
						if params[:remarks] == "Lead Rescheduled"
							rescheduled_leads += 1
						elsif params[:remarks] == "Lead transferred"
							transferred_leads += 1
						end
						if params[:lead][:status]=='-1'
							if @lead_picked.follow_ups.where(last: true)==[]
							else
							last_follow_up=@lead_picked.follow_ups.where(last: true)[0]
							@followup.status=last_follow_up.status
							@followup.osv=last_follow_up.osv
							end
						elsif params[:lead][:status]=='0'
							if @lead_picked.status==false
							else
								@lead_picked.update(osv: nil)
								@followup.osv=nil	
							end
						elsif params[:lead][:status]=='1'
							@followup.osv=true
							@followup.status=nil
							if @lead_picked.qualified_on == nil && @lead_picked.interested_in_site_visit_on == nil
								@lead_picked.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
								
							elsif @lead_picked.qualified_on == nil
								@lead_picked.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date])
								
							elsif @lead_picked.interested_in_site_visit_on == nil
								@lead_picked.update(osv: true, status: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
							else 
								@lead_picked.update(osv: true, status: nil)
							end
							if @lead_picked.visit_organised_on==nil
								@lead_picked.update(visit_organised_on: Time.now)
							end
							if @lead_picked.business_unit_id == 2
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 5
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DEC Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 6
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=	DV Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 3
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=	DWC Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							end
						elsif params[:lead][:status]=='11'
							if @lead_picked.virtually_visited_on != nil
							else
								@lead_picked.update(virtually_visited_on: Time.now)
							end	
							@followup.status=false
							@followup.osv=nil
							if @lead_picked.qualified_on == nil && @lead_picked.interested_in_site_visit_on == nil
								@lead_picked.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
							elsif @lead_picked.qualified_on == nil
								@lead_picked.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date])
							elsif @lead_picked.interested_in_site_visit_on == nil
								@lead_picked.update(status: false, osv: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
							else
								@lead_picked.update(status: false, osv: nil)
							end
						elsif params[:lead][:status]=='2'
							if @lead_picked.site_visited_on != nil
							else
								@lead_picked.update(site_visited_on: Time.now)
								@number='91'+@lead_picked.mobile
								@number=@number.to_s
								if @lead_picked.business_unit.walkthrough!=nil
									@message="Thank you for visiting " + @lead_picked.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead_picked.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead_picked.personnel.name + "%0a" + @lead_picked.personnel.mobile + "%0a"+@lead_picked.business_unit.organisation.name
								else
									if @lead_picked.business_unit.organisation.sender_id=='LABULB'
										@message="Thank you for meeting with us, hope you liked our demo. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead_picked.personnel.name + "%0a" + @lead_picked.personnel.mobile + "%0a"+@lead_picked.business_unit.organisation.name
									else
										@message="Thank you for visiting " + @lead_picked.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead_picked.personnel.name + "%0a" + @lead_picked.personnel.mobile + "%0a"++@lead_picked.business_unit.organisation.name
									end
								end	
								@message=@message.to_s
						  # 		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead_picked.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
								# response=HTTParty.get(urlstring)
							end	
							@followup.status=false
							@followup.osv=nil
							if @lead_picked.qualified_on == nil && @lead_picked.interested_in_site_visit_on == nil
								@lead_picked.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
								
							elsif @lead_picked.qualified_on == nil
								@lead_picked.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date])
								
							elsif @lead_picked.interested_in_site_visit_on == nil
								@lead_picked.update(status: false, osv: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
							else
								@lead_picked.update(status: false, osv: nil)
							end
							if @lead_picked.visit_organised_on==nil
								@lead_picked.update(visit_organised_on: Time.now)
							end
							if @lead_picked.business_unit_id == 2
								dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&mode=DELETE"
								dlt_result = HTTParty.get(dlturlstring)
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DO Site visited&mode=ADD"
								new_add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 5
								dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&mode=DELETE"
								dlt_result = HTTParty.get(dlturlstring)
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DEC Site Visited&mode=ADD"
								new_add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 6
								dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&mode=DELETE"
								dlt_result = HTTParty.get(dlturlstring)
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DV Site Visited&mode=ADD"
								new_add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 3
								dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&mode=DELETE"
								dlt_result = HTTParty.get(dlturlstring)
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DWC Site Visited&mode=ADD"
								new_add_result = HTTParty.get(addurlstring)
							end
						elsif params[:lead][:status]=='3'
							@followup.osv=false
							@followup.status=nil
							@lead_picked.update(osv: false, status: nil)
						elsif params[:lead][:status]=='5'	
							@followup.status=true
							@followup.osv=nil
							@lead_picked.update(status: true, osv: nil)
							@lead_picked.update(booked_on: params[:lead][:flexible_date])
							@lead_picked.update(lost_reason_id: params[:lead][:lost_reason])
							dlturlstring = "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&mode=DELETE"
							dlt_result = HTTParty.get(dlturlstring)
						elsif params[:lead][:status]=='4'	
							@followup.status=true
							@followup.osv=nil
							@lead_picked.update(status: true, osv: nil)
							@lead_picked.update(booked_on: params[:lead][:flexible_date])
						elsif params[:lead][:status]=='9'
							if current_personnel.name == "Shradhya Saha" || current_personnel.name == "Moumita Mitra"
								if current_personnel.last_robin == nil
									current_personnel.update(last_robin: true)
									@lead_picked.update(personnel_id: 156)
								elsif current_personnel.last_robin == true
									current_personnel.update(last_robin: false)
									@lead_picked.update(personnel_id: 291)
								elsif current_personnel.last_robin == false
									current_personnel.update(last_robin: true)
									@lead_picked.update(personnel_id: 156)
								else
									@lead_picked.update(personnel_id: current_personnel.id)
								end
								@followup.status = false
								@followup.osv = true
								if @lead_picked.qualified_on==nil 
									@lead_picked.update(osv: true, status: false, qualified_on: Time.now)
									whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, qualified: true, send_after_days: 0)
									whatsapp_templates.each do |whatsapp_template|
										if whatsapp_template.name_required == true
											if whatsapp_template.template_type == "video with text and quickreply button"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead_picked.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "video","video": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "2", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "==========================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead_picked.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											elsif whatsapp_template.template_type == "image with text and quickreply button"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead_picked.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "image","image": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "2", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "==========================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead_picked.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											elsif whatsapp_template.template_type == "pdf with text and quickreply button"
												urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
												result = HTTParty.post(urlstring,
												:body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead_picked.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title.to_s,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s}}]},{"type": "body","parameters": [{"type": "text","text": "Sir/Mam"}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "2", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
												:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
												p result
												p "==========================="
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = @lead_picked.id
												whatsapp_followup.template_message = whatsapp_template.title.to_s+" sent in whatsapp"
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											end
										else
										end
									end
								else
									@lead_picked.update(osv: true, status: false)	
								end
							else
								@followup.status = false
								@followup.osv = true
								if @lead_picked.qualified_on==nil 
								@lead_picked.update(osv: true, status: false, qualified_on: Time.now)
								
								else
								@lead_picked.update(osv: true, status: false)	
								end
								if @lead_picked.business_unit_id == 2
									addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
									add_result = HTTParty.get(addurlstring)
								elsif @lead_picked.business_unit_id == 5
									addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DEC Qualified&mode=ADD"
									add_result = HTTParty.get(addurlstring)
								elsif @lead_picked.business_unit_id == 6
									addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=	DV Qualified&mode=ADD"
									add_result = HTTParty.get(addurlstring)
								elsif @lead_picked.business_unit_id == 3
									addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=	DWC Qualified&mode=ADD"
									add_result = HTTParty.get(addurlstring)
								end
							end
						elsif params[:lead][:status]=='10'
							@followup.status = false
							@followup.osv = true
							if @lead_picked.interested_in_site_visit_on==nil
								if @lead_picked.qualified_on == nil
									@lead_picked.update(osv: true, status: false, qualified_on: Time.now, interested_in_site_visit_on: Time.now)
									
								else
									@lead_picked.update(osv: true, status: false, interested_in_site_visit_on: Time.now)
								end
							else
								@lead_picked.update(osv: true, status: false)
							end
							if @lead_picked.business_unit_id == 2
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DO Qualified Leads&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 5
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=DEC Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 6
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=	DV Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							elsif @lead_picked.business_unit_id == 3
								addurlstring =  "https://jaingroup.midap.in/api/jaingroup/Api.php?licenseKey=zqP@Ag!GKV^$1660806794%aX&phone="+@lead_picked.mobile.to_s+"&email="+@lead_picked.email.to_s+"&name="+@lead_picked.name.to_s+"&tag=	DWC Qualified&mode=ADD"
								add_result = HTTParty.get(addurlstring)
							end
						end
						if params[:leading][:pincode] == ""
						else
							@lead_picked.update(pincode: params[:leading][:pincode])
						end
						if params[:leading][:age_bracket] == ""
						else
							@lead_picked.update(age_bracket: params[:leading][:age_bracket])
						end
						# if params[:leading][:work_area_id] == ""
						# else
						# 	if params[:leading][:work_area_id] == "-1"
						# 		if params[:work_area_other] == nil
						# 		else
						# 			area = Area.new
						# 			area.name = params[:work_area_other]
						# 			area.organisation_id = current_personnel.organisation_id
						# 			area.save
						# 			@lead_picked.update(work_area_id: area.id)
						# 		end	
						# 	else
						# 		@lead_picked.update(work_area_id: params[:leading][:work_area_id])
						# 	end
						# end
						if params[:leading][:occupation_id] == ""
						else
							if params[:leading][:occupation_id] == "-1"
								if params[:occupation_other] == nil
								else
									occupation = Occupation.new
									occupation.description = params[:occupation_other]
									occupation.organisation_id = current_personnel.organisation_id
									occupation.save
									@lead_picked.update(occupation_id: occupation.id)
								end
							else
								@lead_picked.update(occupation_id: params[:leading][:occupation_id])
							end
						end
						if current_personnel.organisation_id == 6
						else
							if params[:whatsapp_template_ids] == nil
							else
								params[:whatsapp_template_ids].each do |whatsapp_template_id|
									whatsapp_template = WhatsappTemplate.find(whatsapp_template_id.to_i)
									if (whatsapp_template.file_name == nil || whatsapp_template.file_name == '') && (whatsapp_template.file_url == nil || whatsapp_template.file_url == '')
										urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+@lead_picked.mobile.to_s,
							                 :message => whatsapp_template.body,    
							                  :type => "text"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            
							            template_send = TemplateSend.new
										template_send.template = whatsapp_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead_picked.id
										template_send.save	            
							            sleep(5)
							        else
							        	urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
							            result = HTTParty.post(urlstring,
							               :body => { :to_number => '+91'+@lead_picked.mobile.to_s,
							                 :message => whatsapp_template.file_url,    
							                  :text => "",
							                  :type => "media"
							                  }.to_json,
							                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
							            template_send = TemplateSend.new
										template_send.template = whatsapp_template.title+' sent in Whatsapp'
										template_send.lead_id = @lead_picked.id
										template_send.save	            
							            sleep(5)
							        end
								end
							end
							if params[:email_template_ids] == nil
							else
								params[:email_template_ids].each do |email_template_id|
									email_template = EmailTemplate.find(email_template_id.to_i)
									email_data=[email_template.id, current_personnel.id, @lead_picked.id]
									# UserMailer.email_template_send(email_data).deliver
									template_send = TemplateSend.new
									template_send.template = email_template.title+' sent in Whatsapp'
									template_send.lead_id = @lead_picked.id
									template_send.save	            
								end
							end
						end
						@lead_picked.update(anticipation: params[:anticipation])
						@lead_picked.update(escalated: nil, reengaged_on: nil)
						if @lead_picked.follow_ups!=[]
							@lead_picked.follow_ups.each{|x| x.update(last: nil)}
							@followup.scheduled_time=@lead_picked.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
						else
							@followup.first=true	
						end
						@followup.last=true
						@followup.save
						if current_personnel.organisation_id == 1
							if @followup.telephony_call_id == nil
								data = [@followup.id, params[:telephony_call_id]]
								UserMailer.missed_telephony_call(data).deliver
							end
						end
					end	
					if rescheduled_leads == 0
					else
						data = [rescheduled_leads, current_personnel.business_unit_id, current_personnel.id]
						UserMailer.lead_transferring(data).deliver
					end
					if transferred_leads == 0
					else
						data = [transferred_leads, current_personnel.business_unit_id, current_personnel.id]
						UserMailer.lead_transferring(data).deliver
					end
					if current_personnel.organisation_id == 6
						if current_personnel.business_unit.organisation_id == 1
							redirect_to windows_fresh_leads_url
						else
							redirect_to :back
						end
					else
						redirect_to windows_fresh_leads_url
					end
				else
					if params[:lead_id].instance_of? String
					all_leads = [params[:lead_id].to_i]
					else
					all_leads = params[:lead_id]
					end	
					all_leads.each do |lead_id|
						@followup = FollowUp.new
						@picked_lead = Lead.find(lead_id.to_i) 
						@followup.lead_id = lead_id.to_i
						@followup.personnel_id = current_personnel.id
						@followup.communication_time = params[:lead][:flexible_date]
						@followup.follow_up_time = params[:lead][:followup_date]
						followup_hours = params[:lead]['followup_time(4i)'].to_i*60*60
						followup_minutes = params[:lead]['followup_time(5i)'].to_i*60
						@followup.follow_up_time = @followup.follow_up_time+followup_hours+followup_minutes
						@followup.remarks = params[:remarks]
						if params[:lead][:status]=='-1'
							last_follow_up = @picked_lead.follow_ups.where(last: true)[0]
							if last_follow_up == nil
							else
								@followup.status = last_follow_up.status
								@followup.osv = last_follow_up.osv
							end
						elsif params[:lead][:status]=='0'
							if @picked_lead.status==false
							else
								@picked_lead.update(osv: nil)
								@followup.osv=nil	
							end
						elsif params[:lead][:status]=='1'
							@followup.osv=true
							@followup.status=nil
							if @picked_lead.qualified_on == nil && @picked_lead.interested_in_site_visit_on == nil
								@picked_lead.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
								
							elsif @picked_lead.qualified_on == nil
								@picked_lead.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date])
								
							elsif @picked_lead.interested_in_site_visit_on == nil
								@picked_lead.update(osv: true, status: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
							else
								@picked_lead.update(osv: true, status: nil)
							end
							if @picked_lead.visit_organised_on==nil
								@picked_lead.update(visit_organised_on: Time.now)
							end
						elsif params[:lead][:status]=='2'
							if @picked_lead.site_visited_on != nil
							else
								@picked_lead.update(site_visited_on: Time.now)
								@number='91'+@picked_lead.mobile
								@number=@number.to_s
								if @picked_lead.business_unit.walkthrough!=nil
									@message="Thank you for visiting " + @picked_lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a"+@picked_lead.business_unit.organisation.name
								else
									if @picked_lead.business_unit.organisation.sender_id=='LABULB'
									@message="Thank you for meeting with us, hope you liked our demo. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a"+@picked_lead.business_unit.organisation.name
									else
									@message="Thank you for visiting " + @picked_lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a"+@picked_lead.business_unit.organisation.name
									end
								end	
								@message=@message.to_s
						  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
								response=HTTParty.get(urlstring)
								puts response
							end	
							@followup.status=false
							@followup.osv=nil
							if @picked_lead.qualified_on == nil && @picked_lead.interested_in_site_visit_on == nil
								@picked_lead.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
								
							elsif @picked_lead.qualified_on == nil 
								@picked_lead.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date])
								
							elsif @picked_lead.interested_in_site_visit_on == nil
								@picked_lead.update(status: false, osv: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
							else
								@picked_lead.update(status: false, osv: nil)
							end
							if @picked_lead.visit_organised_on==nil
								@picked_lead.update(visit_organised_on: Time.now)
							end
						elsif params[:lead][:status]=='3'
							@followup.osv=false
							@followup.status=nil
							@picked_lead.update(osv: false, status: nil)
						elsif params[:lead][:status]=='5'	
							@followup.status=true
							@followup.osv=nil
							@picked_lead.update(status: true, osv: nil)
							@picked_lead.update(booked_on: params[:lead][:flexible_date])
							@picked_lead.update(lost_reason_id: params[:lead][:lost_reason])
						elsif params[:lead][:status]=='4'	
							@followup.status=true
							@followup.osv=nil
							@picked_lead.update(status: true, osv: nil)
							@picked_lead.update(booked_on: params[:lead][:flexible_date])
						elsif params[:lead][:status]=='9'
							@followup.status = false
							@followup.osv = true
							if @picked_lead.qualified_on==nil
							@picked_lead.update(osv: true, status: false, qualified_on: Time.now)
							
							else
							@picked_lead.update(osv: true, status: false)	
							end
						elsif params[:lead][:status]=='10'
							@followup.status = false
							@followup.osv = true
							if @picked_lead.interested_in_site_visit_on==nil
								if @picked_lead.qualified_on == nil
									@picked_lead.update(osv: true, status: false, qualified_on: Time.now, interested_in_site_visit_on: Time.now)
									
								else
									@picked_lead.update(osv: true, status: false, interested_in_site_visit_on: Time.now)
								end
							else
								@picked_lead.update(osv: true, status: false)
							end
						end
						@picked_lead.update(escalated: nil, reengaged_on: nil)
						@picked_lead.update(anticipation: params[:anticipation])
						if @picked_lead.follow_ups!=[]
							@picked_lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.update(last: nil)
							@followup.scheduled_time=@picked_lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
						else
							@followup.first=true	
						end
						@followup.last=true
						@followup.save
						if @picked_lead.site_visited_on == nil
						else
							if @picked_lead.site_visited_on.to_date == DateTime.now.to_date || @picked_lead.site_visited_on.to_date == DateTime.now.to_date-1.day
								if @picked_lead.personnel_id == current_personnel.id
									if @picked_lead.follow_ups.count == 1
										data = [@picked_lead]
										UserMailer.site_visit_feedback(data).deliver
										sv_message = "Greetings from "+@picked_lead.business_unit.name+"!"+"\n"+"\n"+"Thank you for Visiting "+@picked_lead.business_unit.name+"."+"\n"+"\n"+"We hope you had a pleasant experience during your visit. Kindly provide your rating to help us serve you better."
										urlstring = "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
									    result = HTTParty.post(urlstring,
									      :body => { :to_number => '+91'+@picked_lead.mobile.to_s,
													:message => sv_message,
													:type => "buttons",
									   			:buttons => [{:id => "happy", :text => "😀"}, {:id => "flat", :text => "😑"}, {:id => "sad", :text => "😞"}]
									  		}.to_json,
									      :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
									end
								end
							end
						end		
						redirect_to windows_fresh_leads_url
					end	
				end
			end
		elsif params[:delete]=='Delete'
			data = []
			all_deleted_leads = []
			params[:lead_id].each do |lead_id|
				all_deleted_leads += [Lead.find(lead_id.to_i)]
				FollowUp.where(lead_id: lead_id.to_i).each do |follow_up|
					follow_up.destroy
				end
				SmsFollowup.where(lead_id: lead_id.to_i).each do |follow_up|
					follow_up.destroy
				end
				EmailFollowup.where(lead_id: lead_id.to_i).each do |follow_up|
					follow_up.destroy
				end
				SentCostSheet.where(lead_id: lead_id.to_i).each do |follow_up|
					follow_up.destroy
				end
				Whatsapp.where(lead_id: lead_id.to_i).each do |follow_up|
					follow_up.destroy
				end
				Lead.find(lead_id.to_i).destroy
			end
			data = [all_deleted_leads, current_personnel]
			UserMailer.deleted_leads_report(data).deliver
			redirect_to :back
		elsif params[:sms_followup]=='SMS Followup'
			if current_personnel.status=='Back Office' || current_personnel.status=='Admin'
				all_leads=params[:lead_id]
				all_leads.each do |lead_id|
					sms_followup=SmsFollowup.new
					sms_followup.lead_id=lead_id
					sms_followup.save
					@picked_lead=Lead.find(lead_id)
					if @picked_lead.business_unit.walkthrough==nil
						number='91'+@picked_lead.mobile
						number=number.to_s
				  		text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
				  		text=text.to_s
				  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+ @picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
						response=HTTParty.get(urlstring)
						puts response


				  	else
						number='91'+@picked_lead.mobile
						number=number.to_s
						number='91'+@picked_lead.mobile
				  		text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,\n" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
				  		text=text.to_s		  		
				  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
						response=HTTParty.get(urlstring)
						puts response
				  	end
				end
			else
				lead_id=params[:lead_id]
				sms_followup=SmsFollowup.new
				sms_followup.lead_id=lead_id
				sms_followup.save
				@picked_lead=Lead.find(lead_id)
				if @picked_lead.business_unit.walkthrough==nil
					number='91'+@picked_lead.mobile
					number=number.to_s
			  		text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
			  		text=text.to_s
			  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
					response=HTTParty.get(urlstring)
					puts response
			  	else
					number='91'+@picked_lead.mobile
					number=number.to_s
					number='91'+@picked_lead.mobile
			  		text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,\n" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
			  		text=text.to_s		  		
			  		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
					response=HTTParty.get(urlstring)
					puts response
			  	end
			end
			redirect_to :back
		elsif params[:email_followup] == 'Email Followup'
			if current_personnel.status=='Back Office' || current_personnel.status=='Admin'
				all_leads=params[:lead_id]
				all_leads.each do |lead_id|
					if Lead.find(lead_id).email == nil || Lead.find(lead_id).email == ''
					else
						email_followup=EmailFollowup.new
						email_followup.lead_id=lead_id
						email_followup.save
						data=Lead.find(lead_id)
						UserMailer.email_followup_to_lead(data).deliver
					end
				end
			else
				lead_id=params[:lead_id]
				if Lead.find(lead_id).email == nil || Lead.find(lead_id).email == ''
				else
					email_followup=EmailFollowup.new
					email_followup.lead_id=lead_id
					email_followup.save
					data=Lead.find(lead_id)
					UserMailer.email_followup_to_lead(data).deliver
				end
			end	
			redirect_to :back
		elsif params["Refresh"]=='Refresh'
			if request.referrer.include?('fresh')
				redirect_to :controller => "windows", :action => "fresh_leads", :executive => params[:site_executive][:picked]	
			elsif request.referrer.include?('due')
				redirect_to :controller => "windows", :action => "followup_due", :executive => params[:site_executive][:picked]	
			else
				redirect_to :controller => "windows", :action => "pending_followups", :executive => params[:site_executive][:picked]	
			end
		elsif params["Allocate"]=='Allocate'
			all_leads=params[:lead_id]
			all_leads.each do |lead_id|
				
				Lead.find(lead_id).update(personnel_id: params[:site_executive][:picked].to_i)
				UserMailer.new_lead_notification(Lead.find(lead_id)).deliver
				# lead_for_sms=Lead.find(lead_id)
				# executive_number='91'+lead_for_sms.personnel.mobile
				# if lead_for_sms.mobile != nil && lead_for_sms.email != nil
				# message="Source: "+lead_for_sms.source_category.description+', '+ lead_for_sms.name+", 0"+lead_for_sms.mobile+", "+lead_for_sms.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead_for_sms.id.to_s).short_url
				# elsif lead_for_sms.mobile != nil
				# message="Source: "+lead_for_sms.source_category.description+', '+ lead_for_sms.name+", 0"+lead_for_sms.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead_for_sms.id.to_s).short_url
				# elsif lead_for_sms.email != nil
				# message="Source: "+lead_for_sms.source_category.description+', '+ lead_for_sms.name+", "+lead_for_sms.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead_for_sms.id.to_s).short_url
				# end	
				# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+lead_for_sms.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
				# response=HTTParty.get(urlstring)
			
			end
			redirect_to :controller => "windows", :action => "fresh_leads", :executive => params[:site_executive][:picked]	
		end
	else
		redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
	end
end

def download_site_visit_qr_code
	@lead=Lead.find(params[:lead_id])
	@qr_code_pdf=render_to_string(:partial => "site_visit_qr_code", :layout => false, :locals => { :lead_id => params[:lead_id]})
	@qr_code_pdf='<html><body>'+@qr_code_pdf+'</body></html>'
	@pdf = WickedPdf.new.pdf_from_string(@qr_code_pdf)
	send_data(@pdf, filename: Lead.find(@lead).business_unit.name+'-QR Code for Site Visit'+'.pdf', type: 'application/pdf')
end

def followup_history
	if current_personnel.business_unit.organisation_id == 1
		if params[:update] == nil
			if params[:call_1] == nil
				if params[:call_2] == nil
					if params[:call_other] == nil
					else
						call_btn = "third"
						lead_id = params[:call_other].keys[0]
					end
				else
					call_btn = "second"
					lead_id = params[:call_2].keys[0]
				end
			else
				call_btn = "first"
				lead_id = params[:call_1].keys[0]
			end
			if params[:id] == nil
				@lead = Lead.find(lead_id.to_i)
			else
				@lead = Lead.find(params[:id].to_i)
			end
			if current_personnel.id == @lead.personnel_id
		    	@lead.call_the_customer(call_btn)
		    end
			@age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
			@areas = selections_with_other(Area, :name).sort
			@occupations=selections_with_other(Occupation, :description).sort
			@lost_reasons=selections(LostReason, :description)	
			@common_templates=[]
			@whatsapp_templates = WhatsappTemplate.where(business_unit_id: current_personnel.business_unit_id, inactive: nil).map{|x| [x.title, x.id]}
			@email_templates=[]
			@sms_templates=[]
			@gurukul_whatsapp_templates = ["gurukul_brochure_mobileview", "gurukul_location", "gurukul_project_brief"]
			@common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred", "Called many time but the customer didn't respond", "Called many time but not reachable", "Call Forwarded"]
			if @lead.follow_ups==[] && @lead.whatsapps==[]
				flash[:danger]='no followup history present'
				redirect_to :back
			else
				WhatsappTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |whatsapp_template|
			      @whatsapp_templates+=[[whatsapp_template.title, whatsapp_template.id]]
			    end
			    EmailTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |email_template|
			      @email_templates+=[[email_template.title, email_template.id]]
			    end
			end
		else
			all_leads = params[:lead_id]
			all_leads.each do |lead_id|
				@lead_picked = Lead.find(lead_id.to_i)
				@followup = FollowUp.new
				@followup.personnel_id = current_personnel.id
				@lead_picked.update(personnel_id: params[:lead][:personnel].to_i)
				@followup.lead_id = lead_id
				@followup.communication_time = params[:lead][:flexible_date]
				@followup.follow_up_time = params[:lead][:followup_date]
				followup_hours = params[:lead]['followup_time(4i)'].to_i*60*60
				followup_minutes = params[:lead]['followup_time(5i)'].to_i*60
				@followup.follow_up_time = @followup.follow_up_time+followup_hours+followup_minutes
				@followup.remarks=params[:remarks]
				if params[:lead][:status]=='-1'
					if @lead_picked.follow_ups.where(last: true)==[]
					else
						last_follow_up=@lead_picked.follow_ups.where(last: true)[0]
						@followup.status=last_follow_up.status
						@followup.osv=last_follow_up.osv
					end
				elsif params[:lead][:status]=='0'
					if @lead_picked.status==false
					else
						@lead_picked.update(osv: nil)
						@followup.osv=nil	
					end
				elsif params[:lead][:status]=='1'
					@followup.osv=true
					@followup.status=nil
					if @lead_picked.qualified_on == nil && @lead_picked.interested_in_site_visit_on == nil
						@lead_picked.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
						
					elsif @lead_picked.qualified_on == nil
						@lead_picked.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date])
						
					elsif @lead_picked.interested_in_site_visit_on == nil
						@lead_picked.update(osv: true, status: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
					else 
						@lead_picked.update(osv: true, status: nil)
					end
					if @lead.visit_organised_on==nil
						@lead.update(visit_organised_on: Time.now)
					end
				elsif params[:lead][:status]=='2'
					if @lead_picked.site_visited_on != nil
					else
						@lead_picked.update(site_visited_on: Time.now)
						@number='91'+@lead_picked.mobile
						@number=@number.to_s
						if @lead_picked.business_unit.walkthrough!=nil
							@message="Thank you for visiting " + @lead_picked.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead_picked.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead_picked.personnel.name + "%0a" + @lead_picked.personnel.mobile + "%0a"+@lead_picked.business_unit.organisation.name
						else
							if @lead_picked.business_unit.organisation.sender_id=='LABULB'
								@message="Thank you for meeting with us, hope you liked our demo. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead_picked.personnel.name + "%0a" + @lead_picked.personnel.mobile + "%0a"+@lead_picked.business_unit.organisation.name
							else
								@message="Thank you for visiting " + @lead_picked.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead_picked.personnel.name + "%0a" + @lead_picked.personnel.mobile + "%0a"++@lead_picked.business_unit.organisation.name
							end
						end	
						@message=@message.to_s
				  # 		urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead_picked.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
						# response=HTTParty.get(urlstring)
					end	
					@followup.status=false
					@followup.osv=nil
					if @lead_picked.qualified_on == nil && @lead_picked.interested_in_site_visit_on == nil
						@lead_picked.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
						
					elsif @lead_picked.qualified_on == nil
						@lead_picked.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date])
						
					elsif @lead_picked.interested_in_site_visit_on == nil
						@lead_picked.update(status: false, osv: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
					else
						@lead_picked.update(status: false, osv: nil)
					end
					if @lead.visit_organised_on==nil
						@lead.update(visit_organised_on: Time.now)
					end
				elsif params[:lead][:status]=='3'
					@followup.osv=false
					@followup.status=nil
					@lead_picked.update(osv: false, status: nil)
				elsif params[:lead][:status]=='5'	
					@followup.status=true
					@followup.osv=nil
					@lead_picked.update(status: true, osv: nil)
					@lead_picked.update(booked_on: params[:lead][:flexible_date])
					@lead_picked.update(lost_reason_id: params[:lead][:lost_reason])
				elsif params[:lead][:status]=='4'	
					@followup.status=true
					@followup.osv=nil
					@lead_picked.update(status: true, osv: nil)
					@lead_picked.update(booked_on: params[:lead][:flexible_date])
				elsif params[:lead][:status]=='9'
					@followup.status = false
					@followup.osv = true
					if @lead_picked.qualified_on==nil 
					@lead_picked.update(osv: true, status: false, qualified_on: Time.now)
					
					else
					@lead_picked.update(osv: true, status: false)	
					end
				elsif params[:lead][:status]=='10'
					@followup.status = false
					@followup.osv = true
					if @lead_picked.interested_in_site_visit_on==nil
						if @lead_picked.qualified_on == nil
							@lead_picked.update(osv: true, status: false, qualified_on: Time.now, interested_in_site_visit_on: Time.now)
							
						else
							@lead_picked.update(osv: true, status: false, interested_in_site_visit_on: Time.now)
						end
					else
						@lead_picked.update(osv: true, status: false)
					end
				end
				if params[:leading][:pincode] == ""
				else
					@lead_picked.update(pincode: params[:leading][:pincode])
				end
				if params[:leading][:age_bracket] == ""
				else
					@lead_picked.update(age_bracket: params[:leading][:age_bracket])
				end
				# if params[:leading][:work_area_id] == ""
				# else
				# 	if params[:leading][:work_area_id] == "-1"
				# 		if params[:work_area_other] == nil
				# 		else
				# 			area = Area.new
				# 			area.name = params[:work_area_other]
				# 			area.organisation_id = current_personnel.organisation_id
				# 			area.save
				# 			@lead_picked.update(work_area_id: area.id)
				# 		end	
				# 	else
				# 		@lead_picked.update(work_area_id: params[:leading][:work_area_id])
				# 	end
				# end
				if params[:leading][:occupation_id] == ""
				else
					if params[:leading][:occupation_id] == "-1"
						if params[:occupation_other] == nil
						else
							occupation = Occupation.new
							occupation.description = params[:occupation_other]
							occupation.organisation_id = current_personnel.organisation_id
							occupation.save
							@lead_picked.update(occupation_id: occupation.id)
						end
					else
						@lead_picked.update(occupation_id: params[:leading][:occupation_id])
					end
				end
				@lead_picked.update(anticipation: params[:anticipation])
				@lead_picked.update(escalated: nil, reengaged_on: nil)
				if @lead_picked.follow_ups!=[]
					@lead_picked.follow_ups.each{|x| x.update(last: nil)}
					@followup.scheduled_time=@lead_picked.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
				else
					@followup.first=true	
				end
				@followup.last=true
				@followup.save
			end
			redirect_to :back 
		end
	else
		@flats=[]
		Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
		@flats+=[[flat.floor.to_s+'-'+flat.name,flat.id]]
		end
		@age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
		@areas = selections_with_other(Area, :name).sort
		@occupations=selections_with_other(Occupation, :description).sort
		@lead=Lead.find(params[:id].to_i) 
		@lost_reasons=selections(LostReason, :description)  
		@common_templates=[]
		@whatsapp_templates=[]
		@email_templates=[]
		@sms_templates=[]
		@common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
		if @lead.follow_ups==[] && @lead.whatsapps==[]
			flash[:danger]='no followup history present'
			redirect_to :back
		else
			WhatsappTemplate.where(business_unit_id: @lead.business_unit.id, live: true, inactive: nil).each do |whatsapp_template|
			  @whatsapp_templates+=[whatsapp_template.title]
			end
			EmailTemplate.where(business_unit_id: @lead.business_unit.id, live: true, inactive: nil).each do |email_template|
			  @email_templates+=[email_template.title]
			end
			SmsTemplate.where(business_unit_id: @lead.business_unit.id, live: true, inactive: nil).each do |sms_template|
			  @sms_templates+=[sms_template.title]
			end
		end
	end
end

def month_picker
	@projects=selections(BusinessUnit, :name)
end

def expenditure_entry_form
	# if request.get?
	# 	@projects=selections(BusinessUnit, :name)
	# end
	# if request.post?
	if params[:project] == nil
		# p params[:project]
		# p "first load"
		@projects=selections(BusinessUnit, :name)
		params[:expenditure_entry]=nil
		@sources_used_last_month=[]
		@all_previous_expenditures=Expenditure.includes(:source_category).where(business_unit_id: @business_unit_id, period: @beginning_of_month)
		@source_categories=selections(SourceCategory, :heirarchy)
	else
		@projects=selections(BusinessUnit, :name)
	
		if params[:date]!=nil
			@year=params[:date][:year].to_i
			@month=params[:date][:month].to_i
			@beginning_of_month=DateTime.new(@year, @month, 1)
		else
			@beginning_of_month=(Date.today-1.month).beginning_of_month	
		end
		@business_unit_id=params[:project][:selected].to_i
		@all_previous_expenditures=Expenditure.includes(:source_category).where(business_unit_id: @business_unit_id, period: @beginning_of_month)
		@source_categories=selections(SourceCategory, :heirarchy)
		leads_generated_last_month=Lead.includes(:source_category).where(business_unit_id: params[:project][:selected].to_i).where('leads.generated_on >= ? AND leads.generated_on < ?', @beginning_of_month, @beginning_of_month.end_of_month+1.day)
		@sources_used_last_month=[]
			leads_generated_last_month.each do |lead|
				@sources_used_last_month+=[[lead.source_category.heirarchy, lead.source_category_id]]
			end
		@sources_used_last_month.uniq!.try{|x| x.sort!}		
	end
end

def expenditure_entry
	Expenditure.where(period: params[:expenditure_entry][:date], business_unit_id: params[:business_unit_id]).destroy_all
	if params[:previous_month_sources]!=nil
		params[:previous_month_sources].each do |source_category_id, amount|
			if amount==nil || amount==0 || amount==''
			else	
				expenditure = Expenditure.new
				expenditure.source_category_id = source_category_id.to_i
				expenditure.business_unit_id = params[:business_unit_id]
				expenditure.budgeted_amount = params[:previous_month_budgeted][source_category_id]
				expenditure.budgeted_enquiries = params[:previous_month_budgeted_enquiries][source_category_id]
				expenditure.amount = amount
				expenditure.remarks = params[:previous_month_remarks][source_category_id]
				expenditure.period = params[:expenditure_entry][:date]
				expenditure.save
			end
		end
	end
	params[:budgeted_extra_sources].each do |serial, amount|
		if amount==nil || amount=='' || amount==0 || params[:source_category].select{|key, value| key == serial}.values[0]==nil || params[:source_category].select{|key, value| key == serial}.values[0]==''
		else
			expenditure = Expenditure.new
			expenditure.source_category_id = params[:source_category].select{|key, value| key == serial}.values[0]
			if Expenditure.where(source_category_id: expenditure.source_category_id, period: params[:expenditure_entry][:date], business_unit_id: params[:business_unit_id])==[]
				expenditure.amount = params[:extra_sources][serial]
				expenditure.budgeted_amount = params[:budgeted_extra_sources][serial]
				expenditure.budgeted_enquiries = params[:budgeted_extra_enquiries][serial]
				expenditure.business_unit_id = params[:business_unit_id]
				expenditure.remarks = params[:extra_remarks][serial]
				expenditure.period = params[:expenditure_entry][:date]
				expenditure.save
			end
		end
	end
	redirect_to :controller => "windows", :action => "expenditure_entry_form", :date => {:year => params[:date][:year], :month => params[:date][:month]}, :project => {:selected => params[:business_unit_id]}
end

def fb_google_expenditure_entry_form
	@projects=selections(BusinessUnit, :name)
	if params[:project] == nil
		@business_unit_id = -1
	else
		@business_unit_id = params[:project][:selected]
		@year = params[:date][:year].to_i
		@month = params[:date][:month].to_i
		@beginning_of_month = DateTime.new(@year, @month, 1)
		@source_categories = [['Online . FACEBOOK', 37], ['Online . Google', 1112]]
		@all_previous_expenditures = Expenditure.includes(:source_category).where(business_unit_id: @business_unit_id, period: @beginning_of_month)
		leads_generated_last_month = Lead.includes(:source_category).where(business_unit_id: params[:project][:selected].to_i).where('leads.generated_on >= ? AND leads.generated_on < ?', @beginning_of_month, @beginning_of_month.end_of_month+1.day)
		@sources_used_last_month = []
		leads_generated_last_month.each do |lead|
			@sources_used_last_month += [[lead.source_category.heirarchy, lead.source_category_id]]
		end
		@sources_used_last_month.uniq!.try{|x| x.sort!}		
	end
end

def fb_google_expenditure_entry
	Expenditure.where(period: params[:expenditure_entry][:date], business_unit_id: params[:business_unit_id]).destroy_all
	params[:budgeted_extra_sources].each do |serial, amount|
		if amount==nil || amount=='' || amount==0 || params[:source_category].select{|key, value| key == serial}.values[0] == nil || params[:source_category].select{|key, value| key == serial}.values[0] == ''
		else
			expenditure = Expenditure.new
			expenditure.source_category_id = params[:source_category].select{|key, value| key == serial}.values[0]
			if Expenditure.where(source_category_id: expenditure.source_category_id, period: params[:expenditure_entry][:date], business_unit_id: params[:business_unit_id]) == []
				expenditure.amount = params[:extra_sources][serial]
				expenditure.budgeted_amount = params[:budgeted_extra_sources][serial]
				expenditure.budgeted_enquiries = params[:budgeted_extra_enquiries][serial]
				expenditure.business_unit_id = params[:business_unit_id]
				expenditure.remarks = params[:extra_remarks][serial]
				expenditure.period = params[:expenditure_entry][:date]
				expenditure.save
			end
		end
	end
	redirect_to :controller => "windows", :action => "fb_google_expenditure_entry_form", :date => {:year => params[:date][:year], :month => params[:date][:month]}, :project => {:selected => params[:business_unit_id]}
end

def costing
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:date]!=nil
		@from_year=params[:date][:from_year].to_i
		@from_month=params[:date][:from_month].to_i
		@to_year=params[:date][:to_year].to_i
		@to_month=params[:date][:to_month].to_i
		@business_unit_id=params[:project][:selected].to_i

		@beginning_of_period=DateTime.new(@from_year, @from_month, 1)
		@end_of_period=DateTime.new(@to_year, @to_month, 1).end_of_month

		if params[:project][:selected]==-1
		@source_wise_leads_generated=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('leads.generated_on >= ? AND leads.generated_on <= ?', @beginning_of_period, @end_of_period).group("leads.source_category_id").count
		@source_wise_site_visits=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('leads.generated_on >= ? AND leads.generated_on <= ? AND lead.site_visited_on is not ?', @beginning_of_period, @end_of_period, nil).group("leads.source_category_id").count
		@source_wise_bookings=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: nil).where('leads.generated_on >= ? AND leads.generated_on <= ? AND leads.booked_on is not ?', @beginning_of_period, @end_of_period, nil).group("leads.source_category_id").count
		@source_wise_expenditures=Expenditure.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('expenditures.period >= ? AND expenditures.period <= ?', @beginning_of_period, @end_of_period).group("expenditures.source_category_id").sum("expenditures.amount")
		@source_wise_budgets=Expenditure.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('expenditures.period >= ? AND expenditures.period <= ?', @beginning_of_period, @end_of_period).group("expenditures.source_category_id").sum("expenditures.budgeted_amount")
		else
		@source_wise_leads_generated=Lead.where(business_unit_id: params[:project][:selected].to_i).where('generated_on >= ? AND generated_on <= ?', @beginning_of_period, @end_of_period).group(:source_category_id).count
		@source_wise_site_visits=Lead.joins(:business_unit).where(business_unit_id: params[:project][:selected].to_i).where('leads.generated_on >= ? AND leads.generated_on <= ? AND leads.site_visited_on is not ?', @beginning_of_period, @end_of_period, nil).group(:source_category_id).count
		@source_wise_bookings=Lead.joins(:business_unit).where(business_unit_id: params[:project][:selected].to_i, lost_reason_id: nil).where('leads.generated_on >= ? AND leads.generated_on <= ? AND leads.booked_on is not ?', @beginning_of_period, @end_of_period, nil).group(:source_category_id).count
		@source_wise_expenditures=Expenditure.where(business_unit_id: params[:project][:selected].to_i).where('period >= ? AND period <= ?', @beginning_of_period, @end_of_period).group(:source_category_id).sum(:amount)
		@source_wise_budgets=Expenditure.where(business_unit_id: params[:project][:selected].to_i).where('period >= ? AND period <= ?', @beginning_of_period, @end_of_period).group(:source_category_id).sum(:budgeted_amount)
		end

		@source_wise_expenditures.each do |source_category_id, amount|
			source_category=SourceCategory.find(source_category_id)
			sub_sources=SourceCategory.where(organisation_id: current_personnel.organisation_id).where.not(id: source_category.id).where('heirarchy like ?', '%'+source_category.heirarchy+'%')
			sub_sources.each do |sub_source|
				if @source_wise_leads_generated[sub_source.id]!=nil
					if @source_wise_leads_generated[source_category_id]==nil
					@source_wise_leads_generated[source_category_id]=@source_wise_leads_generated[sub_source.id]
					else 
					@source_wise_leads_generated[source_category_id]=@source_wise_leads_generated[source_category_id]+@source_wise_leads_generated[sub_source.id]
					end
					@source_wise_leads_generated.delete(sub_source.id)
				end
				if @source_wise_site_visits[sub_source.id]!=nil
					if @source_wise_site_visits[source_category_id]==nil
					@source_wise_site_visits[source_category_id]=@source_wise_site_visits[sub_source.id]
					else 
					@source_wise_site_visits[source_category_id]=@source_wise_site_visits[source_category_id]+@source_wise_site_visits[sub_source.id]
					end
					@source_wise_site_visits.delete(sub_source.id)
				end
				if @source_wise_bookings[sub_source.id]!=nil
					if @source_wise_bookings[source_category_id]==nil
					@source_wise_bookings[source_category_id]=@source_wise_bookings[sub_source.id]
					else 
					@source_wise_bookings[source_category_id]=@source_wise_bookings[source_category_id]+@source_wise_bookings[sub_source.id]
					end
					@source_wise_bookings.delete(sub_source.id)
				end
			end
		end
	end
end

def expenditure_edit_form
end

def expenditure_edit_entry
end

def import_leads
end

def import_qualified_leads
end

def qualified_leads_import
	errors = Lead.qualified_lead_import(params[:file])
	if errors>0
		flash[:danger]="Leads imported with error-"+errors.to_s
	else	
		flash[:info]="Leads imported!"
	end
	redirect_to windows_import_qualified_leads_url
end

def import_site_visited_leads
end

def site_visited_leads_import
	errors = Lead.site_visited_lead_import(params[:file])
	if errors>0
		flash[:danger]="Leads imported with error-"+errors.to_s
	else	
		flash[:info]="Leads imported!"
	end
	redirect_to windows_import_site_visited_leads_url
end

def leads_import
if current_personnel.organisation.name=='LightABulb'
errors=Lead.import_with_first_follow_up(params[:file])
else	
errors=Lead.import(params[:file])
end
	if errors.count>0
	flash[:danger]="Leads imported with error-"+errors.count.to_s
	else	
	flash[:info]="Leads imported!"
	end
redirect_to windows_import_leads_url
end

def outbound_call

@urlstring="http://thejaingroup1:cffc27f3aa246eb22b78f08961dd3af71378864f@twilix.exotel.in/v1/Accounts/thejaingroup1/Calls/connect"

HTTParty.post(@urlstring, :body => { "From" => "09831282170", "To" => "09874447669", "CallerId" => "08039591669", "CallerType" => "trans" })


# HTTParty.post(@urlstring, :body => { "From" => "09831282170", "To" => "09230577830", "CallerId" => "09243422233", "CallerType" => "trans" }.to_json, :headers => { 'Content-Type' => 'application/json'})
redirect_to :back
end

def snapshot
render :layout => false	
end

def call
# not being used
@urlstring="http://thejaingroup1:cffc27f3aa246eb22b78f08961dd3af71378864f@twilix.exotel.in/v1/Accounts/thejaingroup1/Calls/connect"

@from='0' + current_personnel.mobile

@to='0' + Lead.find(params[:id]).mobile.at(3..12)

HTTParty.post(@urlstring, :body => { "From" => @from, "To" => @to, "CallerId" => "08039591669", "CallerType" => "trans" })


# HTTParty.post(@urlstring, :body => { "From" => "09831282170", "To" => "09230577830", "CallerId" => "09243422233", "CallerType" => "trans" }.to_json, :headers => { 'Content-Type' => 'application/json'})
redirect_to :back
end


def inbound_call
# not being used
@from=params["From"]

render :text => "09831282170"

end

def call_details
# not being used
render :nothing => true

end

def round_robin
# not being used
	@leads_to_allocate=Lead.where('personnel_id is ? AND business_unit_id is not ?', nil, nil)

	@leads_to_allocate.each do |lead|
		@site_executives=Personnel.where(business_unit_id: lead.business_unit_id).sort_by{|x| [x.id]}
		if Personnel.where(business_unit_id: lead.business_unit_id, round_robin: true)!=[]

		@previous_index=@site_executives.index{ |executive| executive.round_robin == true }
		if @site_executives.count==(@previous_index+1)
		lead.update(personnel_id: @site_executives[0].id)
		@site_executives[0].round_robin_set
		
		
		else	
		lead.update(personnel_id: @site_executives[(@previous_index+1)].id)
		@site_executives[(@previous_index+1)].round_robin_set
		
		end
		@site_executives[(@previous_index)].round_robin_remove
		
		else

		lead.update(personnel_id: @site_executives[0].id)
		@site_executives[0].round_robin_set
		
		end			
	end
redirect_to :back

end


def project_wise_source_wise_bar_chart
@projects=selections_with_all(BusinessUnit, :name)
@executives=selections_with_all(Personnel, :name)
lost_reasons=LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
lost_reasons=lost_reasons-[57,49]
lost_reasons=lost_reasons+[nil]

if params[:project]!= nil
	@project_selected=params[:project][:selected].to_i
else
	@project_selected=-1
end

array_of_executives=[]
if params[:executive]!= nil
	@executive_selected=params[:executive][:selected].to_i
	if @executive_selected==-1
		Personnel.where(organisation_id: current_personnel.organisation_id).each do |executive|
		array_of_executives=array_of_executives+[executive.id]
		end
	else
	array_of_executives=[@executive_selected]
	end
else
	@executive_selected=-1
	Personnel.where(organisation_id: current_personnel.organisation_id).each do |executive|
	array_of_executives=array_of_executives+[executive.id]
	end
end


leads_generated_hash={}
qualified_leads_hash={}
qualification_percentage_hash={}
site_visited_hash={}
site_visit_percentage_hash={}
booked_hash={}
booking_percentage_hash={}

leads_generated_hash[:name]='Enquiries'
qualification_percentage_hash[:name]='QL%'
qualified_leads_hash[:name]='Qualified Leads'
site_visit_percentage_hash[:name]='SV%'
site_visited_hash[:name]='Site visited'
booking_percentage_hash[:name]='Booking%'
booked_hash[:name]='Booked'

leads_generated_data=[]
qualified_leads_data=[]
ql_percentage_data=[]
site_visited_data=[]
sv_percentage_data=[]
booked_data=[]
booked_percentage_data=[]

month_count=6	
@months=[]

count=6
6.times do

@months=@months+[Date::MONTHNAMES[((Time.now)-(month_count.months)).month]]


year=((Time.now)-(month_count.months)).year
month=((Time.now)-(month_count.months)).month
	if @project_selected==-1
	lead_count=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: array_of_executives, lost_reason_id: lost_reasons).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
	leads_generated_data+=[lead_count]
	ql_count=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: array_of_executives).where.not(qualified_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count
	qualified_leads_data+=[ql_count]
	ql_percentage_data+=[((ql_count.to_f/lead_count.to_f)*100).round(2)]
	sv_count=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, personnel_id: array_of_executives).where.not(site_visited_on: nil).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count	
	site_visited_data+=[sv_count]
	sv_percentage_data+=[((sv_count.to_f/ql_count.to_f)*100).round(2)]
	booked_count=Lead.joins(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, lost_reason_id: nil, status: true, personnel_id: array_of_executives).where("extract(year from leads.generated_on) = ? AND extract(month from leads.generated_on) = ?", year, month).count	
	booked_data+=[booked_count]
	booked_percentage_data+=[((booked_count.to_f/sv_count.to_f)*100).round(2)]
	else
	lead_count=Lead.where(business_unit_id: @project_selected, personnel_id: array_of_executives, lost_reason_id: lost_reasons).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count	
	leads_generated_data+=[lead_count]
	ql_count=Lead.where(business_unit_id: @project_selected, personnel_id: array_of_executives).where.not(qualified_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
	qualified_leads_data+=[ql_count]
	ql_percentage_data+=[((ql_count.to_f/lead_count.to_f)*100).round(2)]
	sv_count=Lead.where(business_unit_id: @project_selected, personnel_id: array_of_executives).where.not(site_visited_on: nil).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
	site_visited_data+=[sv_count]
	sv_percentage_data+=[((sv_count.to_f/ql_count.to_f)*100).round(2)]
	booked_count=Lead.where(business_unit_id: @project_selected, lost_reason_id: nil, personnel_id: array_of_executives, status: true).where("extract(year from generated_on) = ? AND extract(month from generated_on) = ?", year, month).count
	booked_data+=[booked_count]
	booked_percentage_data+=[((booked_count.to_f/sv_count.to_f)*100).round(2)]
	end
month_count=month_count-1
end
leads_generated_hash[:data]=leads_generated_data
qualified_leads_hash[:data]=qualified_leads_data
qualification_percentage_hash[:data]=ql_percentage_data
site_visited_hash[:data]=site_visited_data
site_visit_percentage_hash[:data]=sv_percentage_data
booked_hash[:data]=booked_data
booking_percentage_hash[:data]=booked_percentage_data
@series=[leads_generated_hash, qualified_leads_hash, site_visited_hash, booked_hash, qualification_percentage_hash, site_visit_percentage_hash, booking_percentage_hash].to_json.html_safe
@months=@months.to_json.html_safe

end

def project_wise_executive_wise_bar_chart
# last 6 months executivewise leads generated, site visits done, bookings done with projectwise drilldown
end

def project_wise_open_leads_pie_chart
# as on date with drilldown giving breakup of fresh, osv, sitevisited, negotiation	
@executives=selections_with_all(Personnel, :name)

array_of_executives=[]
if params[:executive]!= nil
	@executive_selected=params[:executive][:selected].to_i
	if @executive_selected==-1
		Personnel.where(organisation_id: current_personnel.organisation_id).each do |executive|
		array_of_executives=array_of_executives+[executive.id]
		end
	else
	array_of_executives=[@executive_selected]
	end
else
	@executive_selected=-1
	Personnel.where(organisation_id: current_personnel.organisation_id).each do |executive|
	array_of_executives=array_of_executives+[executive.id]
	end
end


@projects=BusinessUnit.where(organisation_id: current_personnel.organisation_id)
@projects_array=[]

fresh_leads_hash={}
osv_hash={}
site_visited_hash={}
negotiation_hash={}

fresh_leads_hash[:name]='Fresh Leads'
osv_hash[:name]='Site Visits Organised'
site_visited_hash[:name]='Site Visited'
negotiation_hash[:name]='Under Negotiation'

fresh_leads_data=[]
osv_data=[]
site_visited_data=[]
negotiation_data=[]


	@projects.each do |project|
	@projects_array+=[project.name]
	fresh_leads_data+=[Lead.where(business_unit_id: project.id, osv: nil, site_visited_on: nil, personnel_id: array_of_executives).where('status is ? OR status = ?', nil, false).count]
	osv_data+=[Lead.where(business_unit_id: project.id, osv: true, site_visited_on: nil, personnel_id: array_of_executives).where('status is ? OR status = ?', nil, false).count]
	site_visited_data+=[Lead.where(business_unit_id: project.id, osv: nil, personnel_id: array_of_executives).where('status is ? OR status = ?', nil, false).where('site_visited_on is not ?', nil).count]
	negotiation_data+=[Lead.where(business_unit_id: project.id, osv: false, personnel_id: array_of_executives).where('status is ? OR status = ?', nil, false).count]
	end

fresh_leads_hash[:data]=fresh_leads_data
osv_hash[:data]=osv_data
site_visited_hash[:data]=site_visited_data
negotiation_hash[:data]=negotiation_data

@series=[fresh_leads_hash, osv_hash, site_visited_hash, negotiation_hash].to_json.html_safe
@projects_array=@projects_array.to_json.html_safe



end

def executive_wise_open_leads_pie_chart
# as on date with drilldown giving breakup of fresh, osv, sitevisited, negotiation	
end

def site_executive_options
	if current_personnel == nil
		executives = Personnel.where(organisation_id: 1).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
		@executives=[]
		executives.each do |executive|
			@executives+=[[executive.name, executive.id]]
		end
		@executives.sort!
	else
		if current_personnel.mapped == nil || current_personnel.mapped == ""
			if current_personnel.status=='Admin' || current_personnel.status=='Back Office'	|| current_personnel.status=='Sales Executive'	|| current_personnel.status=='Team Lead' || current_personnel.status=='Marketing' || current_personnel.status == "Audit"
				executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ? OR access_right = ?', nil, 2, 4, 0)
				@executives=[]
				executives.each do |executive|
					@executives+=[[executive.name, executive.id]]
				end
				@executives.sort!
			end
		else
			mapped_executive_id = [current_personnel.id]
			mapped_executive_id += [current_personnel.mapped]
			if current_personnel.mapped_two == nil
			else
			 	mapped_executive_id += [current_personnel.mapped_two]
			end
			if current_personnel.mapped_three == nil
			else
				mapped_executive_id += [current_personnel.mapped_three]
			end
			
			executives = Personnel.where(organisation_id: current_personnel.organisation_id, id: mapped_executive_id)
			@executives = []
			executives.each do |executive|
				@executives+=[[executive.name, executive.id]]
			end
			Personnel.where(organisation_id: current_personnel.organisation_id, access_right: 2, expanded: true).each do |personnel|
				if personnel.id == current_personnel.id
				else
					@executives+=[[personnel.name, personnel.id]]
				end
			end
			@executives.sort!
		end
	end
end

	def call_made
		call_record = CallRecord.new
		call_record.contact_name = params[:contact_name]
		call_record.occurred_at = params[:occurred_at]
		call_record.number = params[:to_number]
		call_record.personnel_id=params[:by].to_i
		if call_record.personnel_id==0
		puts params[:by]
		else
			existing_leads=Lead.joins(:business_unit).where(mobile: call_record.number.last(10).to_s, :business_units => {organisation_id: Personnel.find(call_record.personnel_id).organisation_id})
			if existing_leads != []
				call_record.lead_id = existing_leads[0].id
			end
		end
		call_record.call_length = params[:call_length]
		call_record.status = params[:status]
		call_record.save
		render :nothing => true	
	end

	def call_received
		call_record = CallRecord.new
		call_record.contact_name = params[:contact_name]
		call_record.occurred_at = params[:occurred_at]
		call_record.number = params[:from_number]
		call_record.personnel_id=params[:by].to_i
		existing_leads=Lead.joins(:business_unit).where(mobile: call_record.number.last(10).to_s, :business_units => {organisation_id: Personnel.find(call_record.personnel_id).organisation_id})
		if existing_leads != []
			call_record.lead_id = existing_leads[0].id
		end
		call_record.call_length = params[:call_length]
		call_record.status = params[:status]
		call_record.save
		render :nothing => true	
	end

	def call_missed
		call_record = CallRecord.new
		call_record.contact_name = params[:contact_name]
		call_record.occurred_at = params[:occurred_at]
		call_record.number = params[:from_number]
		call_record.personnel_id=params[:by].to_i
		existing_leads=Lead.joins(:business_unit).where(mobile: call_record.number.last(10).to_s, :business_units => {organisation_id: Personnel.find(call_record.personnel_id).organisation_id})
		if existing_leads != []
			call_record.lead_id = existing_leads[0].id
		end
		call_record.call_length = 0
		call_record.status = params[:status]
		call_record.save
		render :nothing => true	
	end

	def call_record_list
		@lost_reasons=selections(LostReason, :description)
		if params[:refresh] == 'Refresh'
			 @from=params[:range][:from]
		    @to=params[:range][:to]
			@call_records = CallRecord.includes(:lead).where(organisation_id: current_personnel.organisation_id).where('created_at >= ? AND created_at <= ?', @from, @to)
		else
			@search_in_navbar = true
			@from=(Date.today)-1
			@to=(Date.today)+1
			@call_records = CallRecord.includes(:lead).where(organisation_id: current_personnel.organisation_id).where('created_at >= ? AND created_at <= ?', @from, @to)
		end
	end

	def call_report
		@search_in_navbar = true
		@call_records = CallRecord.includes(:lead).where(organisation_id: current_personnel.organisation_id)
	end


	def flat_availability
		@projects=selections(BusinessUnit, :name)
		@blocks=[['All', -1]]
		Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
			@blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
		end
		if params[:refresh]=='Refresh'
			project_selected=params[:project][:selected]
			block_selected=params[:project][:block_id]
			status_filter=params[:flat_status][:filter]
			if status_filter==''
				status_filter=nil
			end
			if block_selected=='-1'
				if status_filter=='-1'
				@flats=Flat.includes(:block).where(:blocks => {business_unit_id: project_selected})		
				else
				@flats=Flat.includes(:block).where(:blocks => {business_unit_id: project_selected}, status: status_filter)		
				end
			else
				if status_filter=='-1'
				@flats=Flat.where(block_id: block_selected)
				else
				@flats=Flat.where(block_id: block_selected, status: status_filter)		
				end
			end		
		end

		if params[:update]=='Update'
			status_selected=params[:flat][:status]
			flat_ids=params[:flat_id]
				flat_ids.each do |flat_id|
				flat=Flat.find(flat_id.to_i)
				flat.update(:status => status_selected)
				end
		end
	end


  def fresh_sales_funnel
  	if params.select{|key, value| value == ">" }.keys[0] == nil
  		@from=(Date.today)-30
  	  	@to=(Date.today)
  	  	if params[:lead] != nil
  	    	@from=params[:lead][:from]
  	    	@to=params[:lead][:to]
  	  	end
  		@projects=selections_with_all(BusinessUnit, :name)
  		if params[:project]==nil
  		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
  		else
  			if params[:project][:selected]=='-1'
  			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
  			else
  			project_selected=params[:project][:selected]
  			end
  		end
  		
  		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
  		@site_executives=selections_with_all_active(Personnel, :name)
  			if params[:site_executive]==nil
  			@executive=-1
  			elsif params[:site_executive][:picked]==-1
  			@executive=-1
  			else
  			@executive=params[:site_executive][:picked].to_i	
  			end
  			if @executive==-1	
  			@non_site_visited_leads=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where(site_visited_on: nil).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
  			else
  			@non_site_visited_leads=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
  			end		
  		else
  		@site_visited_leads=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
  		end
  	else
	redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
	end
  end

  def sales_funnel
  	if params.select{|key, value| value == ">" }.keys[0] == nil
  		@from=(Date.today)-30
  	  	@to=(Date.today)
  	  	if params[:lead] != nil
  	    	@from=params[:lead][:from]
  	    	@to=params[:lead][:to]
  	  	end
  		@projects=selections_with_all(BusinessUnit, :name)
  		if params[:project]==nil
  		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
  		else
  			if params[:project][:selected]=='-1'
  			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
  			else
  			project_selected=params[:project][:selected]
  			end
  		end
  		
  		if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
  		@site_executives=selections_with_all_active(Personnel, :name)
  			if params[:site_executive]==nil
  			@executive=-1
  			elsif params[:site_executive][:picked]==-1
  			@executive=-1
  			else
  			@executive=params[:site_executive][:picked].to_i	
  			end
  			if @executive==-1	
  			@site_visited_leads=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
  			else
  			@site_visited_leads=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
  			end		
  		else
  		@site_visited_leads=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
  		end
  	else
	redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
	end
  end	

	def cost_sheet
		@standalone_cost_sheet = params[:standalone_cost_sheet]
  		if @standalone_cost_sheet=="true"
	  		@business_units=[['All', -1]]
			BusinessUnit.where(organisation_id: current_personnel.organisation_id).each do |business_unit|
				@business_units+=[[business_unit.name,business_unit.id]]
			end
			@car_parks=[]#CarPark.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
		end
		@blocks=[['All', -1]]
		Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
			@blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
		end
		@blocks = @blocks.sort_by{|x| x[0]}
		@flats=[]
		Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
			@flats+=[[flat.block.name+'-'+flat.floor.to_s+'-'+flat.name,flat.id]]
		end	

		@payment_plans=[]
		PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |payment_plan|
			@payment_plans+=[[(payment_plan.business_unit.name+'-'+payment_plan.description),payment_plan.id]]
		end	
		if @standalone_cost_sheet !="true"
		lead=Lead.find(params[:lead_id])
		@car_parks=CarPark.where(business_unit_id: lead.business_unit_id)
		end
		@car_park_natures=selections(CarParkNature, :description)


		if params[:review]=="Review"
			redirect_to :controller => "windows", :action => "cost_sheet_review", :params => request.request_parameters	
		end
	end  
  def cost_sheet_review
  	@standalone_cost_sheet = params[:standalone_cost_sheet]
  	if @standalone_cost_sheet == "true"
  		@business_unit_id = params[:project][:business_unit_id].to_i
  	else
  		lead = Lead.find(params[:lead_id])
  		@business_unit_id = lead.business_unit_id	
  	end
  	
  	selected_block_id = params[:project][:block_id]
  	@selected_flat_id = params[:flat_status][:flat_id]
    @selected_payment_plan = params[:flat_status][:payment_plan_id]
    if current_personnel.organisation_id == 6
    	if params[:remarks_for_validation] == nil
    	else
    		@remarks_for_validation = params[:remarks_for_validation]
    	end
    end
    if params[:final] == nil
 		@final = nil
    else
    	@final = params[:final]
    end
    if current_personnel.organisation_id != 6
	    if params[:servant_quarter]='yes'
		    @servant_quarters=ServantQuarter.where(business_unit_id: @business_unit_id)
		    @servant_quarter_quantity=params[:servant_quarter_quantity].to_i
	    end
	end
    @car_parks=[]
    params[:quantity].each do |key,value|
	    if value==''
	    else
		    car_park=CarPark.where(car_park_nature_id: key, business_unit_id: @business_unit_id)[0]
		    @car_parks+=[[car_park,value.to_i]]
	    end
    end
    @car_parks_quantity=params[:quantity]
    tax_hash=Tax.from_to_hash(@business_unit_id)
    @tax=Tax.find(tax_hash.keys.last)
    
    select_flat = Flat.find(@selected_flat_id)
    extra_development_charge=ExtraDevelopmentCharge.where(business_unit_id: @business_unit_id)[0]
    if extra_development_charge.flat_type==nil || extra_development_charge.flat_type==''
       @extra_development_charges=ExtraDevelopmentCharge.where(business_unit_id: @business_unit_id)
    else
       @extra_development_charges=ExtraDevelopmentCharge.where(business_unit_id: @business_unit_id, flat_type: select_flat.BHK)
    end
    if current_personnel.organisation_id == 6
    	select_flat.update(rate: params[:flat][:rate])
    else
	    if params[:flat][:discount_rate] == "" || params[:flat][:discount_rate] == nil
	    	select_flat.update(rate: params[:flat][:rate])
	    else
	    	updated_rate = params[:flat][:rate].to_f - params[:flat][:discount_rate].to_f
	    	select_flat.update(rate: updated_rate)
	    end
	end

    @posession_charges=PosessionCharge.where(business_unit_id: @business_unit_id)
    @milestones=Milestone.where(payment_plan_id: @selected_payment_plan).sort_by{|x| x.order}
    render :layout => false
  end

  def cost_sheet_download_or_mail
  	@lead_id=nil
  	@lead_id=params[:lead_id]
  	if current_personnel.organisation_id == 6
  		@cost_sheet_pdf=render_to_string(:partial => "cost_sheet_review", :layout => false, :locals => { :lead_id => params[:lead_id], :business_unit_id => params[:business_unit_id],:flat_id => params[:flat_id], :payment_plan_id => params[:payment_plan_id], :car_parks_quantity => params[:car_parks_quantity], :discount =>params[:discount], :remarks_for_validation => params[:remarks_for_validation], :standalone_cost_sheet => params[:standalone_cost_sheet]})
  	else
  		@cost_sheet_pdf=render_to_string(:partial => "cost_sheet_review", :layout => false, :locals => { :lead_id => params[:lead_id], :business_unit_id => params[:business_unit_id],:flat_id => params[:flat_id], :payment_plan_id => params[:payment_plan_id], :servant_quarter_quantity => params[:servant_quarter_quantity], :car_parks_quantity => params[:car_parks_quantity], :discount =>params[:discount], :standalone_cost_sheet => params[:standalone_cost_sheet]})
  	end
  	@cost_sheet_pdf=render_to_string(:partial => "cost_sheet_review", :layout => false, :locals => { :lead_id => params[:lead_id], :business_unit_id => params[:business_unit_id],:flat_id => params[:flat_id], :payment_plan_id => params[:payment_plan_id], :servant_quarter_quantity => params[:servant_quarter_quantity], :car_parks_quantity => params[:car_parks_quantity], :discount =>params[:discount], :remarks_for_validation => params[:remarks_for_validation]})
	@cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
	@pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
	if params[:final] == nil
		@final = nil
	else
		@final = params[:final]
	end
	if params[:email]=='Email'
	    data=[@pdf,@lead_id]
   		cost_sheet=CostSheet.new
		cost_sheet.lead_id=@lead_id
		cost_sheet.servant_quarters=params[:servant_quarter_quantity]
		cost_sheet.payment_plan_id=params[:payment_plan_id]
		cost_sheet.flat_id=params[:flat_id]
		cost_sheet.discount_amount=params[:discount]
		cost_sheet.rate = params[:cost_sheet][:rate]
		if params[:final] == nil
		else
			cost_sheet.final = params[:final]
		end
		cost_sheet.save
		if params[:car_parks_quantity]==nil
		else
			eval(params[:car_parks_quantity]).each do |key,value|
			if value==''
		    else
			cost_sheet_car_parking=CostSheetCarParking.new
			cost_sheet_car_parking.cost_sheet_id=cost_sheet.id
			cost_sheet_car_parking.car_parking_nature_id=key
			cost_sheet_car_parking.quantity=value
			cost_sheet_car_parking.save
			end
			end
		end

  		sent_cost_sheet=SentCostSheet.new
	   	sent_cost_sheet.lead_id=@lead_id
	   	sent_cost_sheet.cost_sheet_id=cost_sheet.id
	   	sent_cost_sheet.save
	   	UserMailer.cost_sheet_to_customer(data).deliver
		redirect_to :controller => "windows", :action => "followup_history", :id => @lead_id
	elsif params[:Whatsapp]=='Whatsapp'
		cost_sheet=CostSheet.new
		cost_sheet.lead_id=@lead_id
		cost_sheet.servant_quarters=params[:servant_quarter_quantity]
		cost_sheet.payment_plan_id=params[:payment_plan_id]
		cost_sheet.flat_id=params[:flat_id]
		cost_sheet.discount_amount=params[:discount]
		cost_sheet.rate = params[:cost_sheet][:rate]
		if params[:final] == nil
		else
			cost_sheet.final = params[:final]
		end
		cost_sheet.save
		if params[:car_parks_quantity]==nil
		else
			eval(params[:car_parks_quantity]).each do |key,value|
			if value==''
		    else
			cost_sheet_car_parking=CostSheetCarParking.new
			cost_sheet_car_parking.cost_sheet_id=cost_sheet.id
			cost_sheet_car_parking.car_parking_nature_id=key
			cost_sheet_car_parking.quantity=value
			cost_sheet_car_parking.save
			end
			end
		end

  		sent_cost_sheet=SentCostSheet.new
	   	sent_cost_sheet.lead_id=@lead_id
	   	sent_cost_sheet.cost_sheet_id=cost_sheet.id
	   	sent_cost_sheet.save
	   	lead = Lead.find(@lead_id.to_i)
	   	urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
  		result = HTTParty.get(urlstring,
		   :body => { :phone => "91"+(lead.mobile),
		              :body => @pdf,
		              :filename => 'cost sheet.pdf' 
		              }.to_json,
		   :headers => { 'Content-Type' => 'application/json' } )
	   	
	   	redirect_to :controller => "windows", :action => "followup_history", :id => @lead_id
	elsif params[:save]=='Save'
	    
   		cost_sheet=CostSheet.new
		cost_sheet.lead_id=@lead_id
		cost_sheet.servant_quarters=params[:servant_quarter_quantity]
		cost_sheet.payment_plan_id=params[:payment_plan_id]
		cost_sheet.flat_id=params[:flat_id]
		cost_sheet.discount_amount=params[:discount]
		cost_sheet.rate = params[:cost_sheet][:rate]
		if params[:final] == nil
		else
			cost_sheet.final = params[:final]
		end
		cost_sheet.save
		if params[:car_parks_quantity]==nil
		else
			eval(params[:car_parks_quantity]).each do |key,value|
			if value==''
		    else
			cost_sheet_car_parking=CostSheetCarParking.new
			cost_sheet_car_parking.cost_sheet_id=cost_sheet.id
			cost_sheet_car_parking.car_parking_nature_id=key
			cost_sheet_car_parking.quantity=value
			cost_sheet_car_parking.save
			end
			end
		end

	redirect_to :controller => "windows", :action => "followup_history", :id => @lead_id
	elsif params[:download]=='Download'
	    send_data(@pdf, filename: 'Cost sheet.pdf', type: 'application/pdf')
	end
  end

  	def cost_sheet_send
	  	@cost_sheet=CostSheet.find(params[:sent_cost_sheet_id])
	  	@lead=Lead.find(@cost_sheet.lead_id)
	  	@selected_flat_id=@cost_sheet.flat_id
	  	@car_parks=[]
	  	CostSheetCarParking.where(cost_sheet_id: @cost_sheet.id).each do|cost_sheet_car_park_nature|
		  	car_park=CarPark.find_by(car_park_nature_id: cost_sheet_car_park_nature.car_parking_nature_id, business_unit_id: @cost_sheet.flat.block.business_unit_id)
			@car_parks+=[[car_park,cost_sheet_car_park_nature.quantity]]
	  	end
	  	@extra_development_charges=ExtraDevelopmentCharge.where(business_unit_id: @lead.business_unit_id, flat_type: @cost_sheet.flat.BHK)
	  	if @extra_development_charges==[]
	  		@extra_development_charges=ExtraDevelopmentCharge.where(business_unit_id: @lead.business_unit_id)	
	  	end
	  	tax_hash=Tax.from_to_hash(@lead.business_unit_id)
	  	if @cost_sheet.bookings[0]==nil
	  	tax=Tax.find(tax_hash.keys.last)
	  	else
	  	booking_date=@cost_sheet.bookings[0].date
	  		tax_hash.each do |tax_id, from_to_array|
	  			if booking_date >= from_to_array[0] && booking_date < from_to_array[1]
	  				tax=Tax.find(tax_id)
	  			end
	  		end
	  	end
	  	if tax==nil	
	  	tax=Tax.where(business_unit: @lead.business_unit_id)[0]
	  	end
	  	@tax=tax
	  	@servant_quarters=ServantQuarter.where(business_unit_id: @lead.business_unit_id)
	  	@servant_quarter_quantity=@cost_sheet.servant_quarters
	  	@discount=@cost_sheet.discount_amount
	  	@milestones=Milestone.where(payment_plan_id: @cost_sheet.payment_plan_id).sort_by{|x| x.order}
	  	@posession_charges=PosessionCharge.where(business_unit_id: @lead.business_unit_id)
	  	render :layout => false
	end

	def cost_sheet_send_edit
	    @cost_sheet=CostSheet.find(params[:format])
	    @car_parks=CarPark.where(business_unit_id: @cost_sheet.lead.business_unit_id)
	    @payment_plans=[]
	    PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |payment_plan|
	    	@payment_plans+=[[payment_plan.description, payment_plan.id]]
	    end	
	    @demand_created=0
	    if LedgerEntryHeader.includes(:booking).where(:bookings => {cost_sheet_id: @cost_sheet.id}) == []
	    	@demand_created=0
	    else
	    	@demand_created=1
	    end
  	end

	def cost_sheet_send_update
		cost_sheet=CostSheet.find(params[:cost_sheet_id])
		cost_sheet.update(discount_amount: params[:cost_sheet][:discount_amount], servant_quarters: params[:cost_sheet][:servant_quarters])
		if params[:cost_sheet][:payment_plan_id]==nil
			cost_sheet.update(rate: params[:cost_sheet][:rate])
		else
			cost_sheet.update(payment_plan_id: params[:cost_sheet][:payment_plan_id], rate: params[:cost_sheet][:rate])
		end

		flat=Flat.find(cost_sheet.flat.id)
		flat.update(rate: params[:cost_sheet][:rate])
		@car_parks_quantity=params[:quantity]
		if params[:quantity]==nil
		else
		  params[:cost_sheet_car_parking_ids].each do |cost_sheet_car_parking_id|
		    @car_parks_quantity.each do |key,value|
		      if value==''
		      else
		        cost_sheet_car_parking=CostSheetCarParking.find(cost_sheet_car_parking_id)
		        cost_sheet_car_parking.update(cost_sheet_id: cost_sheet.id, car_parking_nature_id: key, quantity: value)
		      end
		    end
		  end
		end

		flash[:Success]='Cosh sheet Updated Successfully.'
	    redirect_to demand_bookings_path
	end

	def payment_milestone_index
    	@payment_milestones = PaymentMilestone.where(organisation_id: current_personnel.organisation_id)
  	end

  	def payment_milestone_new
	  	#@organisations=select_options(Organisation, :name)
	    @payment_milestone=PaymentMilestone.new
	    @payment_milestone_action='payment_milestone_create'
  	end
  	def payment_milestone_create
	    @payment_milestone = PaymentMilestone.new(payment_milestone_params)
	    @payment_milestone.organisation_id=current_personnel.organisation_id
	    @payment_milestone.save
	    flash[:info]='payment_milestone was successfully created.'
	    redirect_to windows_payment_milestone_index_url
 	end
  	def payment_milestone_edit
	  	#@orgnaisations=select_options(Organisation, :name)
	  	@payment_milestones = selections(PaymentMilestone, :description)
	    @payment_milestone=PaymentMilestone.find(params[:format])
	    @payment_milestone_lists=[]
	    PaymentMilestone.where(organisation_id: current_personnel.organisation_id).each do |payment_milestone|
	    	if payment_milestone.id == @payment_milestone.id
	    	else
	    		@payment_milestone_lists+=[[payment_milestone.description, payment_milestone.id]]
	    	end
	    end
	    @payment_milestone_action='payment_milestone_update'  
  	end

  	def payment_milestone_update
	    @payment_milestone=PaymentMilestone.find(params[:payment_milestone_id])
	    @payment_milestone.organisation_id=current_personnel.organisation_id
	    @payment_milestone.update(payment_milestone_params)
	    if params[:payment_milestone][:block_level] == 'true'
	    	@payment_milestone.update(block_level: true)
	    else
	    	@payment_milestone.update(block_level: nil)
	    end
	    if params[:payment_milestone][:floor_level] == 'true'
	    	@payment_milestone.update(floor_level: true)
	    else
	    	@payment_milestone.update(floor_level: nil)
	    end
	    @time_based_milestones=TimeBasedMilestone.where(previous_payment_milestone_id: @payment_milestone.id.to_i)
	  	@time_based_milestones.destroy_all
	  	
	  	if params[:payment_milestone_ids] == []
	  	else
		  	params[:payment_milestone_ids].each_with_index do |payment_milestone_id, index|
		  		time_based_milestone=TimeBasedMilestone.new
		  		time_based_milestone.previous_payment_milestone_id = @payment_milestone.id.to_i
		  		time_based_milestone.subsequent_payment_milestone_id = payment_milestone_id.to_i
		  		time_based_milestone.days_after = params[:days_after][index]
		  		time_based_milestone.save
		  	end
		end

	    flash[:info]='payment_milestone was successfully updated.'
	    redirect_to windows_payment_milestone_index_url
  	end

  	def payment_milestone_destroy
	    @payment_milestone=PaymentMilestone.find(params[:format])
	    @payment_milestone.destroy
	    flash[:info]='payment_milestone was successfully destroyed.'
	    redirect_to windows_payment_milestone_index_url
  	end

  	def populate_flats
  		block_id=(params[:block_id]).to_i
  		@flats=[]
  		Flat.where(block_id: block_id).each do |flat|
  			if CostSheet.find_by_flat_id(flat.id) == nil
  				@flats+=[[flat.block.name+'-'+flat.floor.to_s+'-'+flat.name,flat.id]]
			else
				booking = Booking.find_by_cost_sheet_id(CostSheet.find_by_flat_id(flat.id).id)
	  			if booking == nil
	  				@flats+=[[flat.block.name+'-'+flat.floor.to_s+'-'+flat.name,flat.id]]
	  			else
	  				if booking.cancelled == true
	  					@flats+=[[flat.block.name+'-'+flat.floor.to_s+'-'+flat.name,flat.id]]
	  				end
	  			end
	  		end
  		end
  		respond_to do |format|
	    format.js { render :action => "populate_flats"}
		end
  	end	

  	def populate_project_rate
  		block_id=(params[:block_id]).to_i
  		business_unit = BusinessUnit.find((Block.find(block_id.to_i).business_unit_id))
  		@project_rates = ProjectRate.where(business_unit_id: business_unit.id)
  		@specific_project_rate = @project_rates.sort_by{|x| x.date}.last
  		respond_to do |format|
	    	format.js { render :action => "populate_project_rate"}
		end
  	end	

  	def populate_payment_plans
  		block_id=(params[:block_id]).to_i
  		@payment_plans=[]
  		PaymentPlan.where(business_unit_id: Block.find(block_id).business_unit_id).each do |payment_plan|
  			@payment_plans+=[[payment_plan.business_unit.name+'-'+payment_plan.description, payment_plan.id]]
  		end
  		respond_to do |format|
	    format.js { render :action => "populate_payment_plans"}
		end
  	end	

  	def populate_car_parks
  		business_unit_id = (params[:business_unit_id]).to_i
  		@car_parks=[]
  		@car_parks=CarPark.where(business_unit_id: business_unit_id)
  
  		respond_to do |format|
	    	format.js { render :action => "populate_car_parks"}
		end
  	end

  	def absolute_lost
  	end

  	def alive_again
  	end	
  	
  	def whatsapp_snippet

  		 lead=Lead.find(params[:leading_id])
  		 flat=Flat.find(params[:snippet][:flat_id])
  		 message="Hi,\n\n"
  		 message+="*Row Bungalow No - "+flat.floor.to_s+"*\n"
  		 message+="Type - "+flat.name+"\n"
  		 message+="Total Carpet Area as per HIRA- "+flat.carpet_area.round.to_s+" sft \n"
  		 # message+="Balcony Carpet Area- "+flat.first_floor_balcony_carpet.round.to_s+" sft \n"
  		 message+="Total Built Up Area - "+flat.flat_bua.round.to_s+" sft \n"
  		 message+="Total Land Area - "+flat.land_area.to_s+" Cottah"+"\n"
  		 message+="BHK - "+flat.BHK+"\n"
  		 message+="Bungalow Price - "+(sprintf('%.2f', flat.price))+"\n"
  		 message+="GST on Bungalow-"+(sprintf('%.2f', flat.price*0.05))+"\n"
  		 total_extra_charges=0
  		 gst_on_extra_charges=0
  		 extra_development_charges=ExtraDevelopmentCharge.where(business_unit_id: BusinessUnit.find_by_name('Southern Vista').id)
	  		 extra_development_charges.each do |extra_development_charge|
	  		 	if extra_development_charge.rate != nil
	  		 		total_extra_charges+=(flat.flat_bua*extra_development_charge.rate)
	  		 	elsif extra_development_charge.amount != nil
	  		 		total_extra_charges+=extra_development_charge.amount
	  		 	end
	  		 end

  		 message+="Total Extra Charges - "+(sprintf('%.2f', total_extra_charges))+"\n"

  		 gst_on_bungalow_price=flat.price*0.05
  		 gst_on_extra_charges=total_extra_charges*0.18
  		 total_gst=gst_on_bungalow_price+gst_on_extra_charges

  		 message+="GST on Extra Charges- "+(sprintf('%.2f', total_extra_charges*0.18))+"\n"

  		 posession_charges=PosessionCharge.where(business_unit_id: BusinessUnit.find_by_name('Southern Vista').id)
  		 maintenance_amount=flat.flat_bua*posession_charges[0].rate*12
  		 gst_on_maintenance_amount=maintenance_amount*0.18
  		 message+="Maintenance + GST - "+(sprintf('%.2f', maintenance_amount+gst_on_maintenance_amount))+"\n"
  		 message+="Total Consideration(Inc all) + 1 CP - "+(sprintf('%.2f', (flat.price+total_extra_charges+gst_on_bungalow_price+gst_on_extra_charges+maintenance_amount+gst_on_maintenance_amount)))+"\n"

  		 mark_up=0
  		 if params['mark_up']==nil || params['mark_up']=='' || params['mark_up']==0 
  		 else
  		 mark_up=params['mark_up'].to_f
  		 end

  		if params[:cost_sheet]=='Whatsapp Bungalow Snippet'

  		 urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
  		         @result = HTTParty.post(urlstring,
  		            :body => { :to_number => '+91'+current_personnel.mobile,
  		              :message => message,    
  		               :type => "text"
  		               }.to_json,
  		               :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

  		 #  urlstring =  "https://eu71.chat-api.com/instance226994/sendMessage?token=gfzvtsw22h4eps80"
  		 #      result = HTTParty.get(urlstring,
  		 #  :body => { :phone => '91'+(current_personnel.mobile),
  		 #            :body => message
  		 #            }.to_json,
  		 # :headers => { 'Content-Type' => 'application/json' } )	
  		 
  		 elsif params[:cost_sheet]=='Whatsapp Basic Cost Breakup'

  		  		  	@cost_sheet_pdf=render_to_string(:partial => "cost_sheet_convert", :layout => false, :locals => {:lead_id => lead.id, :flat_id => flat.id, :mark_up => mark_up})
  		  			@cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
  		  			@pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
  		  		  	@pdf=Base64.encode64(@pdf) 
  		  		  	@pdf='data:application/pdf;base64,'+@pdf
  		  		  	
  		  			# urlstring =  "https://eu71.chat-api.com/instance226994/sendFile?token=gfzvtsw22h4eps80"
  		    	# 		result = HTTParty.get(urlstring,
  		  		 #   	:body => { :phone => '91'+current_personnel.mobile,
  		  		 #              :body => @pdf,
  		  		 #              :filename => 'Basic Cost Breakup.pdf' 
  		  		 #              }.to_json,
  		  		 #   :headers => { 'Content-Type' => 'application/json' } )
  		 
  		    		urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
                    @result = HTTParty.post(urlstring,
                       :body => { :to_number => '+91'+current_personnel.mobile,
                         :message => @pdf,    
                          :text => "",
                          :type => "media"
                          }.to_json,
                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
                          	

  		 elsif params[:cost_sheet]=='Whatsapp Area Details'
  		  		  	@cost_sheet_pdf=render_to_string(:partial => "area_statement_convert", :layout => false, :locals => {:lead_id => lead.id, :flat_id => flat.id, :mark_up => mark_up})
  		  			@cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
  		  			@pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
  		  		  	@pdf=Base64.encode64(@pdf) 
  		  		  	@pdf='data:application/pdf;base64,'+@pdf
  		  		  	
  		  			urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
                    @result = HTTParty.post(urlstring,
                       :body => { :to_number => '+91'+current_personnel.mobile,
                         :message => @pdf,    
                          :text => "",
                          :type => "media"
                          }.to_json,
                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
                    

  		  			# urlstring =  "https://eu71.chat-api.com/instance226994/sendFile?token=gfzvtsw22h4eps80"
  		    	# 		result = HTTParty.get(urlstring,
  		  		 #   	:body => { :phone => '91'+current_personnel.mobile,
  		  		 #              :body => @pdf,
  		  		 #              :filename => 'Area Details.pdf' 
  		  		 #              }.to_json,
  		  		 #   :headers => { 'Content-Type' => 'application/json' } )
  		 
  		 elsif params[:cost_sheet]=='Email Area Details'
  		  		  	@cost_sheet_pdf=render_to_string(:partial => "area_statement_convert", :layout => false, :locals => {:lead_id => lead.id, :flat_id => flat.id, :mark_up => mark_up})
  		  			@cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
  		  			@pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
  		  		  	
  		  			UserMailer.bungalow_snippet_area([current_personnel,@pdf,flat]).deliver
  		 
  		 elsif params[:cost_sheet]=='Whatsapp Cost Breakup'
  		 	#Row Bungalow Cost, Club charges, Electrification, Legal charges, Incidental charges, charges for formation of association, maintenance deposit
  		  		  	@cost_sheet_pdf=render_to_string(:partial => "payment_sheet_convert", :layout => false, :locals => {:lead_id => lead.id, :flat_id => flat.id, :mark_up => mark_up})
  		  			@cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
  		  			@pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
  		  		  	@pdf=Base64.encode64(@pdf) 
  		  		  	@pdf='data:application/pdf;base64,'+@pdf
  		  		  	
  		  			urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
                    @result = HTTParty.post(urlstring,
                       :body => { :to_number => '+91'+current_personnel.mobile,
                         :message => @pdf,    
                          :text => "",
                          :type => "media"
                          }.to_json,
                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
                    
  		  			
  		  			# urlstring =  "https://eu71.chat-api.com/instance226994/sendFile?token=gfzvtsw22h4eps80"
  		    	# 		result = HTTParty.get(urlstring,
  		  		 #   	:body => { :phone => '91'+current_personnel.mobile,
  		  		 #              :body => @pdf,
  		  		 #              :filename => 'Cost Breakup.pdf' 
  		  		 #              }.to_json,
  		  		 #   :headers => { 'Content-Type' => 'application/json' } )
  		 elsif params[:cost_sheet]=='Email Cost Breakup'
  		 	#Row Bungalow Cost, Club charges, Electrification, Legal charges, Incidental charges, charges for formation of association, maintenance deposit
  		  		  	@cost_sheet_pdf=render_to_string(:partial => "payment_sheet_convert", :layout => false, :locals => {:lead_id => lead.id, :flat_id => flat.id, :mark_up => mark_up})
  		  			@cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
  		  			@pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
  		  		  	UserMailer.bungalow_snippet([current_personnel,@pdf,flat]).deliver   			
  		 end 		 
  		 redirect_to :back
  	end

  	def cost_sheet_convert
  		@lead=Lead.find(params[:lead_id])
  		@flat=Flat.find(params[:flat_id])
  	end
	
  	def all_live_leads_index
  		@business_units = selections_with_all(BusinessUnit, :name)
		executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
		@executives=[]
		executives.each do |executive|
			@executives+=[[executive.name, executive.id]]
		end
		@executives.sort!
  		if request.get?
  			@executive=current_personnel.id
  			@leads=current_personnel.all_live_leads
  		else
  			if params[:commit] == 'Refresh'
  				if params[:business_unit_id] == nil 
  					@selected_business_unit_id = Personnel.find(@executive).business_unit_id
  				elsif params[:business_unit_id] == '-1' || params[:business_unit_id] == -1
  					@selected_business_unit_id=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
  				else
  					@selected_business_unit_id = params[:business_unit_id].to_i
  				end
  				@executive = params[:site_executive][:current_executive].to_i	
  				@site_visited = params[:site_visited]
  				@qualified = params[:qualified]
  				@interested = params[:interested]
  				@since = params[:since]
  				if @site_visited == nil && @qualified == nil && @interested == nil
  					if @executive == -1
  						executives = Personnel.where(business_unit_id: @selected_business_unit_id).pluck(:id)
	  					@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel, :whatsapps).where( :follow_ups => { :lead_id => nil }, :leads => { :status => nil, personnel_id: executives})
	  					@leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true }, :leads => { personnel_id: executives}).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('(leads.status is ? OR leads.status = ?)', nil, false)
	  					@leads+=Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true }, :leads => { personnel_id: executives}).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('(leads.status is ? OR leads.status = ?)', nil, false)
  					else
  						if @since == ""
  							@leads = Personnel.find(@executive).all_live_leads
  						else
  							@leads = Personnel.find(@executive).live_leads_with_since(@since)
  						end
  					end
  				else
  					if @site_visited == nil && @interested == nil
  						# qualified
  						if @since == ""
	  						if @executive == -1
	  							@leads=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, interested_in_site_visit_on: nil, site_visited_on: nil).where.not(qualified_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  						else
	  							@leads = Personnel.find(@executive).all_qualified_leads
	  						end
	  					else
	  						if @executive == -1
	  							@leads=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, interested_in_site_visit_on: nil, site_visited_on: nil).where.not(qualified_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  						else
	  							@leads = Personnel.find(@executive).specific_qualified_leads(@since)
	  						end
	  					end
  					elsif @site_visited == nil && @qualified == nil 
  						#interested in site_visit
  						if @since == ""
	  						if @executive == -1
	  							@leads=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, site_visited_on: nil, visit_organised_on: nil).where.not(interested_in_site_visit_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  						else
	  							@leads = Personnel.find(@executive).all_interested_leads
	  						end
	  					else
	  						if @executive == -1
	  							@leads=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, site_visited_on: nil, visit_organised_on: nil).where.not(interested_in_site_visit_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  						else
	  							@leads = Personnel.find(@executive).specific_interested_leads(@since)
	  						end
	  					end
  					elsif @qualified == nil && @interested == nil
  						# site visited
  						if @since == ""
		  					if @executive==-1
		  						executives = Personnel.where(business_unit_id: @selected_business_unit_id).pluck(:id)
			  					@leads=[]
	  							executives.each do |executive|
	  								@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
			      					@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
	  							end
		  					else
							    @leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil})
			      				@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil}) 					
		  					end
		  				else
		  					if @executive==-1
		  						executives = Personnel.where(business_unit_id: @selected_business_unit_id).pluck(:id)
			  					@leads=[]
	  							executives.each do |executive|
	  								@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
			      					@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
	  							end
		  					else
							    @leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil})
			      				@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil}) 					
		  					end
		  				end
	  				else
	  					if @since == ""
	  						if @executive == -1
	  							@leads=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, interested_in_site_visit_on: nil, site_visited_on: nil).where.not(qualified_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  							@leads+=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, site_visited_on: nil, visit_organised_on: nil).where.not(interested_in_site_visit_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  							executives = Personnel.where(business_unit_id: @selected_business_unit_id).pluck(:id)
			  					executives.each do |executive|
	  								@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
			      					@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
	  							end	
	  							@leads = @leads.uniq
	  						else
	  							@leads = Personnel.find(@executive).all_qualified_leads
	  							@leads += Personnel.find(@executive).all_interested_leads
	  							@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil})
		      					@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil}) 						
		      					@leads = @leads.uniq
	  						end
	  					else
	  						if @executive == -1
	  							@leads=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, interested_in_site_visit_on: nil, site_visited_on: nil).where.not(qualified_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  							@leads+=Lead.where(business_unit_id: @selected_business_unit_id, booked_on: nil, site_visited_on: nil, visit_organised_on: nil).where.not(interested_in_site_visit_on: nil).where('leads.generated_on >= ?', @since.to_datetime)
	  							executives = Personnel.where(business_unit_id: @selected_business_unit_id).pluck(:id)
			  					executives.each do |executive|
	  								@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
			      					@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
	  							end
	  							@leads = @leads.uniq
	  						else
	  							@leads = Personnel.find(@executive).specific_qualified_leads(@since)
	  							@leads += Personnel.find(@executive).specific_interested_leads(@since)
	  							@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil})
			      				@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ? AND leads.site_visited_on >= ?', nil, false, @since.to_datetime.beginning_of_day).where(:leads => { :personnel_id => @executive}).where.not(:leads => {site_visited_on: nil})
			      				@leads = @leads.uniq
	  						end
	  					end
	  				end
  				end
  			elsif params[:commit] == 'Transfer Leads'
  				lead_ids = params[:lead_id]
  				alloted_executive=params[:site_executive][:alloted_executive].to_i	
  				lead_ids.each do |lead_id|
  					lead = Lead.find(lead_id.to_i)
					lead.update(personnel_id: alloted_executive.to_i)
				end
				redirect_to windows_all_live_leads_index_url
			else
				redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])	
  			end
  		end
  	end
	def whatsapp_responsiveness_report
		@business_units=selections(BusinessUnit, :name)
		@whatsapp_types=['Summary Report', 'Day Wise Report']
		@whatsapp_messages=[{'Brochure' => ['Brochure']}, {"photo" => ["view", "gallery", "photo"]}, {"Location" => ['Location', 'Timing']}, {"Floor Plans" => ['Floor Plan']}, {"Expert_chat" => ['kindly click']}, {"Walkthrough" => ['youtu']}, {"Price" => ['price']}, {"Call" => ['executive will get in touch']}, {"Site Visit" => ['preferred date']}, {"Company Profile" => ['about', 'story']}, {"Thanks" => ['welcome', 'anytime']}, {"Ok" => ['thank you for']}, {"Hi" => ['above key work']}, {"Site Visit Confirmation" => ['duly noted']}, {"Availability" => ['Availability']}, {"Possession" => ['Posession']}, {"Loan" => ['Loan', 'EMI']}, {"Payment" => ['Payment']}, {"Failure" => ["Sorry"]}, {"Introductory" => ['Introductory']}]
		if params[:report_type]==nil 
		else
			@selected_whatsapp_report = params[:report_type]
		end
		@from=DateTime.now.beginning_of_month
		@to=DateTime.now.end_of_month

		if @selected_whatsapp_report == 'Summary Report'
			@business_unit_id=params[:business_unit_id]
			@from=params[:from]
			@to=params[:to]
			@whatsapps=Whatsapp.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('whatsapps.created_at >= ? and whatsapps.created_at <= ?', @from.to_datetime.beginning_of_day, @to.to_datetime.end_of_day).where(by_lead: nil)
			@all_whatsapps={}
			@whatsapp_messages.each do |message|
				message.each do |key, value|
					value.each do |message_hint|
						@whatsapps.each do |whatsapp|
							if key == "Expert_chat"
								if whatsapp.message[0..11].downcase == "kindly click"
									if @all_whatsapps[key]==nil
										@all_whatsapps[key]=1
									else
										@all_whatsapps[key]=@all_whatsapps[key]+1
									end
								end
							else
								if whatsapp.message.downcase.include?(message_hint.downcase) == true
									if @all_whatsapps[key]==nil
										@all_whatsapps[key]=1
									else
										@all_whatsapps[key]=@all_whatsapps[key]+1
									end
								end
							end
						end
					end
				end
			end
		elsif @selected_whatsapp_report == 'Day Wise Report'
			@business_unit_id=params[:business_unit_id]
			@from=params[:from]
			@to=params[:to]
			@all_whatsapps={}
			@day_wise_reports=[]
			@from.upto(@to).each do |date|
				whatsapps=Whatsapp.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where(by_lead: nil).where('whatsapps.created_at >= ? and whatsapps.created_at <= ?', date.to_datetime.beginning_of_day, date.to_datetime.end_of_day)
				@all_whatsapps["date"]=date
				@whatsapp_messages.each do |message|
					message.each do |key, value|
						value.each do |message_hint|
							if whatsapps == []
								@all_whatsapps[key]=''
							else
								whatsapps.each do |whatsapp|
									if key == "Expert_chat"
										if @all_whatsapps[key]==nil
											@all_whatsapps[key]=''
										end
										if whatsapp.message[0..11].downcase == "kindly click"
											if @all_whatsapps[key]==''
												@all_whatsapps[key]=1
											else
												@all_whatsapps[key]=@all_whatsapps[key]+1
											end
										end
									else
										if @all_whatsapps[key]==nil
											@all_whatsapps[key]=''
										end
										if whatsapp.message.downcase.include?(message_hint.downcase) == true
											if @all_whatsapps[key]==''
												@all_whatsapps[key]=1
											else
												@all_whatsapps[key]=@all_whatsapps[key]+1
											end
										end
									end
								end
							end
						end
					end
				end
				@day_wise_reports+=[@all_whatsapps]
				@all_whatsapps={}
			end
		end
	end

	def customer_report
		@business_units=selections(BusinessUnit, :name)
		@how_soon=['Immediately','Within 3 months','Within 6 months','Not decided']
		# @parameters=["Occupation","Designation","Favourite Newspaper","Favourite TV Channel","Favourite Radio Station","Favourite Magazine","Community","Nationality","Gender", "Budget", "BHK", "Preferred Location", "Other Projects", "Age", "Years Married", "Pincode", "Investor", "How Soon", "Area", "Work Area"]
		@parameters=["Occupation", "Age", "Area", "Work Area"]
		@parameters=@parameters.sort
		if params[:business_unit_id] == nil
			@from=DateTime.now.beginning_of_month
			@to=DateTime.now.end_of_month
		else
			@selected_business_unit_id = params[:business_unit_id]
			@from = params[:from]
			@to = params[:to]
			@selected_parameters = params[:selected_parameters]
			leads = Lead.where(business_unit_id: @selected_business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', @from.to_datetime.beginning_of_day, @to.to_datetime.end_of_day)
			@all_parameters=[]
			data = [@selected_business_unit_id, @from, @to, current_personnel]
			@selected_parameters.each do |parameter|
				if parameter == 'Occupation'
					occupation = Occupation.occupation_wise_lead(data)
					@occupation_wise_reports = occupation[0]
					@unselected_occupations={"leads" => occupation[1], "qualified" => occupation[2], "site visit" => occupation[3], "booked" => occupation[4]}
				elsif parameter == 'Area'
					area = Area.area_wise_lead(data)
					@area_wise_reports = area[0]
					@unselected_areas={"leads" => area[1], "qualified" => area[2], "site visit" => area[3], "booked" => area[4]}
				elsif parameter == 'Work Area'
					work_area = Area.work_area_wise_lead(data)
					@work_area_wise_reports = work_area[0]
					@unselected_work_areas={"leads" => work_area[1], "qualified" => work_area[2], "site visit" => work_area[3], "booked" => work_area[4]}
				elsif parameter == 'Age'
					young = 0
					young_qualified_lead = 0
					young_site_visited_lead = 0
					young_booked_lead = 0
					middle = 0
					middle_qualified_lead = 0
					middle_site_visited_lead = 0
					middle_booked_lead = 0
					old = 0
					old_qualified_lead = 0
					old_site_visited_lead = 0
					old_booked_lead = 0
					unselected = 0
					unselected_qualified_lead = 0
					unselected_site_visited_lead = 0
					unselected_booked_lead = 0
					leads.where.not(age_bracket: nil).each do |lead|
						if lead.age_bracket == "Young"
							young += 1
							if lead.qualified_on != nil
								young_qualified_lead += 1
							end
							if lead.osv==nil && lead.status==false
								young_site_visited_lead += 1
							end
							if lead.status==true && lead.lost_reason_id==nil
								young_booked_lead += 1
							end
						elsif lead.age_bracket == "Middle Age"
							middle += 1
							if lead.qualified_on != nil
								middle_qualified_lead += 1
							end
							if lead.osv==nil && lead.status==false
								middle_site_visited_lead += 1
							end
							if lead.status==true && lead.lost_reason_id==nil
								middle_booked_lead += 1
							end
						elsif lead.age_bracket == "Old Age"
							old += 1
							if lead.qualified_on != nil
								old_qualified_lead += 1
							end
							if lead.osv==nil && lead.status==false
								old_site_visited_lead += 1
							end
							if lead.status==true && lead.lost_reason_id==nil
								old_booked_lead += 1
							end
						else
							unselected += 1
							if lead.qualified_on != nil
								unselected_qualified_lead += 1
							end
							if lead.osv==nil && lead.status==false
								unselected_site_visited_lead += 1
							end
							if lead.status==true && lead.lost_reason_id==nil
								unselected_booked_lead += 1
							end	
						end
					end
					young_data = {"Young Age" => young, "qualified" => young_qualified_lead, "site visit" => young_site_visited_lead, "booked" => young_booked_lead}
					middle_data = {"Middle Age" => middle, "qualified" => middle_qualified_lead, "site visit" => middle_site_visited_lead, "booked" => middle_booked_lead}
					old_data = {"Old Age" => old, "qualified" => old_qualified_lead, "site visit" => old_site_visited_lead, "booked" => old_booked_lead}
					unselected_data = {"Unselected" => unselected, "qualified" => unselected_qualified_lead, "site visit" => unselected_site_visited_lead, "booked" => unselected_booked_lead}
					@all_dobs = [young_data, middle_data, old_data, unselected_data]
				end
			end
		end
	end
	
  def populate_lost_reason
      @lost_reason_type=params[:type]
      @lost_reasons=selections_with_all(LostReason, :description)
      
      if @lost_reason_type == "Lost"
	      respond_to do |format|
	          format.js { render :action => "populate_lost_reason"}
	      end
	  end
  end

  def google_lead_details
  	@business_units = selections(BusinessUnit, :name)
  	@report_types = ["Network", "Campaing Id", "Device", "Placement", "Keyword", "Extention Id", "Target Id", "Adposition", "Source Id", "Loc Interest MS", "Loc Physical MS"]
  	if params[:report_type] == nil
  		@from = DateTime.now.beginning_of_month-1.month
  		@to = DateTime.now
  		@report_type = nil
		@business_unit_id = BusinessUnit.find_by_name('Dream Exotica').id
  	else
  		@business_unit_id = params[:business_unit][:business_unit_id]
  		@report_type = params[:report_type]
  		@from = params[:from].to_datetime
  		@to = params[:to].to_datetime
  		if @report_type == "Network"
  			@network_hash = {}
  			all_networks = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.network is not ? OR google_lead_details.network = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.network}
  			if all_networks == []
  			else
  				all_networks = all_networks.uniq
	  			all_networks.each do |network|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.network = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', network, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@network_hash[network] = number_of_leads
	  			end
	  		end
  		elsif @report_type == "Campaing Id"
  			# @google_lead_details = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.network is not ? OR google_lead_details.network = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day)
		elsif @report_type == "Device"
			@keyword_hash = {}
			all_devices = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.device is not ? OR google_lead_details.device = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.device}
  			if all_devices == []
  			else
  				all_devices = all_devices.uniq
	  			all_devices.each do |device|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.device = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', device, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@device_hash[placement] = number_of_leads
	  			end
	  		end
		elsif @report_type == "Placement"
			@placement_hash = {}
  			all_placements = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.placement is not ? OR google_lead_details.placement = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.placement}
  			if all_placements == []
  			else
  				all_placements = all_placements.uniq
	  			all_placements.each do |placement|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.placement = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', placement, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@placement_hash[placement] = number_of_leads
	  			end
	  		end
		elsif @report_type == "keyword"
			@keyword_hash = {}
			all_keywords = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.keyword is not ? OR google_lead_details.keyword = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.keyword}
  			if all_keywords == []
  			else
  				all_keywords = all_keywords.uniq
	  			all_keywords.each do |keyword|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.keyword = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', keyword, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@keyword_hash[placement] = number_of_leads
	  			end
	  		end
		elsif @report_type == "Extention Id"
			@extention_id_hash = {}
			all_extention_ids = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.extention_id is not ? OR google_lead_details.extention_id = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.extention_id}
  			if all_extention_ids == []
  			else
  				all_extention_ids = all_extention_ids.uniq
	  			all_extention_ids.each do |extention_id|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.extention_id = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', extention_id, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@extention_id_hash[extention_id] = number_of_leads
	  			end
	  		end
		elsif @report_type == "Target Id"
			@target_id_hash = {}
			all_target_ids = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.target_id is not ? OR google_lead_details.target_id = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.target_id}
  			if all_target_ids == []
  			else
  				all_target_ids = all_target_ids.uniq
	  			all_target_ids.each do |target_id|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.target_id = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', target_id, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@target_id_hash[target_id] = number_of_leads
	  			end
	  		end
		elsif @report_type == "Adposition"
			@adposition_hash = {}
			all_adpositions = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.adposition is not ? OR google_lead_details.adposition = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.adposition}
  			if all_adpositions == []
  			else
  				all_adpositions = all_adpositions.uniq
	  			all_adpositions.each do |adposition|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.adposition = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', adposition, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@adposition_hash[adposition] = number_of_leads
	  			end
	  		end
		elsif @report_type == "Source Id"
			@source_id_hash = {}
			all_source_ids = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.source_id is not ? OR google_lead_details.source_id = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.source_id}
  			if all_source_ids == []
  			else
  				all_source_ids = all_source_ids.uniq
	  			all_source_ids.each do |source_id|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.source_id = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', source_id, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@source_id_hash[source_id] = number_of_leads
	  			end
	  		end
		elsif @report_type == "Loc Interest MS"
			@loc_interest_ms_hash = {}
			all_loc_interest_mses = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.loc_interest_ms is not ? OR google_lead_details.loc_interest_ms = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.loc_interest_ms}
  			if all_loc_interest_mses == []
  			else
  				all_loc_interest_mses = all_loc_interest_mses.uniq
	  			all_loc_interest_mses.each do |loc_interest_ms|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.loc_interest_ms = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', loc_interest_ms, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@loc_interest_ms_hash[loc_interest_ms] = number_of_leads
	  			end
	  		end
		elsif @report_type == "Loc Physical MS"
			@loc_physical_ms_hash = {}
			all_loc_physical_mses = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.loc_physical_ms is not ? OR google_lead_details.loc_physical_ms = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?',nil, "", @from.beginning_of_day, @to.beginning_of_day+1.day).map{|x| x.loc_physical_ms}
  			if all_loc_physical_mses == []
  			else
  				all_loc_physical_mses = all_loc_physical_mses.uniq
	  			all_loc_physical_mses.each do |loc_physical_ms|
	  				number_of_leads = GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i}).where('google_lead_details.loc_physical_ms = ? AND google_lead_details.created_at >= ? AND google_lead_details.created_at < ?', loc_physical_ms, @from.beginning_of_day, @to.beginning_of_day+1.day).count
	  				@loc_physical_ms_hash[loc_physical_ms] = number_of_leads
	  			end
	  		end
		end
  	end
  	# if params[:business_unit]==nil
    #   @google_lead_details=GoogleLeadDetail.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
    #   @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    # else
    #   @business_unit_id=params[:business_unit][:business_unit_id]
    #   @google_lead_details=GoogleLeadDetail.includes(:lead).where(:leads => {business_unit_id: @business_unit_id.to_i})	
    # end
  end

  def site_visit_form
  	@lead = Lead.find(params[:format])
  	@occupations=selections_with_other(Occupation, :description)
  	@designations=selections_with_other(Designation, :description)
  	@nationalities = selections_with_other(Nationality, :description)
  	@companies = selections_with_other(Company, :name)
  	@other_projects=selectoptions(OtherProject, :name)
  	@business_units = selections(BusinessUnit, :name)
  	@areas = selections_with_other(Area, :name)
  	@blocks = selectoptions(Block, :name)
  	@newspapers=selections_with_other(Newspaper, :description)
    @channels=selections_with_other(Channel, :description)
    @stations=selections_with_other(Station, :description)
    @magazines=selections_with_other(Magazine, :description)
    @source_categories=SourceCategory.leaves(current_personnel)
	@source_categories+=[[@lead.source_category.heirarchy, @lead.source_category_id]]   
	@source_pick=[@lead.source_category.heirarchy, @lead.source_category_id]
	position_1 = @lead.name[0..5].index(" ")
	if position_1 == nil
	    @actual_name_1 = @lead.name
	else
	    @title_1 = @lead.name[0..position_1-1]
	    @actual_name_1 = @lead.name[position_1+1..@lead.name.length]
	end
  end

  def site_visit_form_submit
  	lead = Lead.find(params[:lead_id].to_i)
  	lead.update(name: params[:lead][:name], email: params[:lead][:email], mobile: params[:lead][:mobile], dob: params[:lead][:dob].to_datetime, company: params[:lead][:company], pincode: params[:lead][:pincode], address: params[:lead][:address], work_address: params[:lead][:work_address], site_visited_on: DateTime.now)
  	if params[:lead][:occupation_id] == "-1"
  		occupation = Occupation.new
  		occupation.description = params[:occupation][:other]
  		occupation.organisation_id = current_personnel.organisation_id
  		occupation.save
  		lead.update(occupation_id: occupation.id)
  	else
  		lead.update(occupation_id: params[:lead][:occupation_id])
  	end
  	if params[:lead][:designation_id] == "-1"
  		designation = Designation.new
  		designation.description = params[:designation][:other]
  		designation.organisation_id = current_personnel.organisation_id
  		designation.save
  		lead.update(designation_id: designation.id)
  	else
  		lead.update(designation_id: params[:lead][:designation_id])
  	end
  	if params[:purchasing_type] == nil
  		lead.update(investment: nil)
  	elsif params[:purchasing_type] == "investment"
  		lead.update(investment: true)
  	elsif params[:purchasing_type] == "residential"
  		lead.update(investment: false)
  	end
  	if params[:other_project] == ""
  	else
  		other_project = OtherProject.new
  		other_project.name = params[:other_project]
  		other_project.organisation_id = current_personnel.organisation_id
  		other_project.save

		other_project_tag = OtherProjectTag.new
		other_project_tag.other_project_id = other_project.id
		other_project_tag.lead_id = lead.id
		other_project_tag.save
  	end
  	if params[:flat_type] == nil
  	else
  		if params[:flat_type] == "1 BHK"
  			lead.update(flat_type: 1)
  		elsif params[:flat_type] == "2 BHK"
  			lead.update(flat_type: 2)
		elsif params[:flat_type] == "3 BHK"
			lead.update(flat_type: 3)
		elsif params[:flat_type] == "4 BHK"
			lead.update(flat_type: 4)
		elsif params[:flat_type] == "5 BHK"
			lead.update(flat_type: 5)
		end
  	end
  	if params[:budget] == nil
  	else
  		if params[:budget] == "60-80 L"
  			lead.update(budget_from: 60, budget_to: 80)
  		elsif params[:budget] == "80 L-1 Cr"
  			lead.update(budget_from: 80, budget_to: 1)
		elsif params[:budget] == "1-1.5 Cr"
			lead.update(budget_from: 1, budget_to: 2)
		elsif params[:budget] == "Above 1.5 Cr"
			lead.update(budget_from: 2, budget_to: 3)
		end
  	end
  	if params[:how_long] == nil
  	else
  		if params[:how_long] == "1 Month"
  			lead.update(searching_since: "1 Month")
  		elsif params[:how_long] == "3 Month"
  			lead.update(searching_since: "3 Month")
		elsif params[:how_long] == "6 Month"
			lead.update(searching_since: "6 Month")
		elsif params[:how_long] == "More than that"
			lead.update(searching_since: "More than 6 month")
		end
  	end
  	if params[:how_soon] == nil
  	else
  		if params[:how_soon] == "1 Month"
  			lead.update(how_soon: "1 Month")
  		elsif params[:how_soon] == "2 Month"
  			lead.update(how_soon: "2 Month")
  		elsif params[:how_soon] == "3 Month"
  			lead.update(how_soon: "3 Month")
		elsif params[:how_soon] == "4 Month"
			lead.update(how_soon: "4 Month")
		elsif params[:how_soon] == "More than that"
			lead.update(how_soon: "More than 4 month")
		end
  	end
  	if params[:signature_data] == ""
  	else
  		signature_data = params[:signature_data]
  		lead.update(sv_form_signature: signature_data)
	end
	flash[:success] = "Form submited successfully."
  	redirect_to :back
  end

  def walk_in_sv_form
  	@occupations=selections_with_other(Occupation, :description)
  	@designations=selections_with_other(Designation, :description)
  	if params[:source_category_id] == nil
  		@source_category = ""
  	else
  		@source_category = SourceCategory.find(params[:source_category_id])
  	end
  end

  def walk_in_site_visit_form_submit
  	lead = Lead.new
  	lead.name = params[:lead][:name]
  	lead.email = params[:lead][:email]
  	lead.mobile = params[:lead][:mobile]
  	lead.address = params[:lead][:address]
  	lead.dob = params[:lead][:dob]
  	lead.company = params[:lead][:company]
  	lead.pincode = params[:lead][:pincode]
  	lead.site_visited_on = DateTime.now
  	lead.business_unit_id = current_personnel.business_unit_id
  	if params[:source_category_id] == nil
  		lead.source_category_id = 592
  	else
  		lead.source_category_id = params[:source_category_id].to_i
  	end
  	lead.personnel_id = current_personnel.id
  	lead.work_address = params[:lead][:work_address]
  	lead.generated_on = DateTime.now
  	lead.save
  	if params[:lead][:occupation_id] == "-1"
  		occupation = Occupation.new
  		occupation.description = params[:occupation][:other]
  		occupation.organisation_id = current_personnel.organisation_id
  		occupation.save
  		lead.update(occupation_id: occupation.id)
  	else
  		lead.update(occupation_id: params[:lead][:occupation_id])
  	end
  	if params[:lead][:designation_id] == "-1"
  		designation = Designation.new
  		designation.description = params[:designation][:other]
  		designation.organisation_id = current_personnel.organisation_id
  		designation.save
  		lead.update(designation_id: designation.id)
  	else
  		lead.update(designation_id: params[:lead][:designation_id])
  	end
  	if params[:purchasing_type] == nil
  		lead.update(investment: nil)
  	elsif params[:purchasing_type] == "investment"
  		lead.update(investment: true)
  	elsif params[:purchasing_type] == "residential"
  		lead.update(investment: false)
  	end
  	if params[:other_project] == ""
  	else
  		other_project = OtherProject.new
  		other_project.name = params[:other_project]
  		other_project.organisation_id = current_personnel.organisation_id
  		other_project.save

		other_project_tag = OtherProjectTag.new
		other_project_tag.other_project_id = other_project.id
		other_project_tag.lead_id = lead.id
		other_project_tag.save
  	end
  	if params[:flat_type] == nil
  	else
  		if params[:flat_type] == "1 BHK"
  			lead.update(flat_type: 1)
  		elsif params[:flat_type] == "2 BHK"
  			lead.update(flat_type: 2)
		elsif params[:flat_type] == "3 BHK"
			lead.update(flat_type: 3)
		elsif params[:flat_type] == "4 BHK"
			lead.update(flat_type: 4)
		elsif params[:flat_type] == "5 BHK"
			lead.update(flat_type: 5)
		end
  	end
  	if params[:budget] == nil
  	else
  		if params[:budget] == "60-80 L"
  			lead.update(budget_from: 60, budget_to: 80)
  		elsif params[:budget] == "80 L-1 Cr"
  			lead.update(budget_from: 80, budget_to: 1)
		elsif params[:budget] == "1-1.5 Cr"
			lead.update(budget_from: 1, budget_to: 2)
		elsif params[:budget] == "Above 1.5 Cr"
			lead.update(budget_from: 2, budget_to: 3)
		end
  	end
  	if params[:how_long] == nil
  	else
  		if params[:how_long] == "1 Month"
  			lead.update(searching_since: "1 Month")
  		elsif params[:how_long] == "3 Month"
  			lead.update(searching_since: "3 Month")
		elsif params[:how_long] == "6 Month"
			lead.update(searching_since: "6 Month")
		elsif params[:how_long] == "More than that"
			lead.update(searching_since: "More than 6 month")
		end
  	end
  	if params[:how_soon] == nil
  	else
  		if params[:how_soon] == "1 Month"
  			lead.update(how_soon: "1 Month")
  		elsif params[:how_soon] == "2 Month"
  			lead.update(how_soon: "2 Month")
  		elsif params[:how_soon] == "3 Month"
  			lead.update(how_soon: "3 Month")
		elsif params[:how_soon] == "4 Month"
			lead.update(how_soon: "4 Month")
		elsif params[:how_soon] == "More than that"
			lead.update(how_soon: "More than 4 month")
		end
  	end
  	if params[:signed] == ""
  	else
  		signature_data = params[:signed]
  		lead.update(sv_form_signature: signature_data)
	end
  	flash[:success] = "Form submited successfully."
  	redirect_to windows_sv_form_index_url
  end

  def sv_form_index
  	@sources = []
  	SourceCategory.where(organisation_id: current_personnel.organisation_id, inactive: nil).where('heirarchy like ?', '%Agent%').each do |source_category|
  		@sources += [[source_category.heirarchy, source_category.id]]
  	end
  	@sources += ["Others"]
  	@found_leads = []
	if params[:commit] == "Search"
		lead_name = params[:lead_name]
		@found_leads = []
		Lead.where(business_unit_id: current_personnel.business_unit_id, lost_reason_id: nil).each do |lead|
			if lead.name.downcase.include?(lead_name.downcase) == true
				@found_leads += [lead]
			end
		end
	elsif params[:commit] == "Walk In"
		redirect_to :controller => "windows", :action => "sv_personnel_detail_form", params: request.request_parameters
	elsif params[:commit] == "Broker Visit"
		if params[:other_broker] == nil
			redirect_to :controller => "windows", :action => "sv_personnel_detail_form", :source_category_id => (params[:broker_source_category_id])
		else
			source_category = SourceCategory.new
			source_category.description = params[:other_broker]
			source_category.organisation_id = current_personnel.organisation_id
			source_category.predecessor = 60
			source_category.heirarchy = source_category_concatenate(source_category.description, source_category.predecessor.to_i)
			source_category.save

			redirect_to :controller => "windows", :action => "sv_personnel_detail_form", :source_category_id => (source_category.id)
		end
	else
		if params[:page_name] == nil
		else
			@broker_lead_intimation = BrokerLeadIntimation.find(params[:broker_lead_intimation].to_i)
			leads = Lead.where(business_unit_id: @broker_lead_intimation.business_unit_id).where('mobile like ? and name like ?', @broker_lead_intimation.mobile+'%', '%'+@broker_lead_intimation.name+'%')
			if leads == []
				redirect_to :controller => "windows", :action => "sv_personnel_detail_form", :broker_lead_intimation => params[:broker_lead_intimation].to_i, :source_category_id => 60
			else
				@found_leads = leads
			end
		end
	end

  end

  def populate_other_broker
  	@broker_name = params[:broker_name]
  	p @broker_name
  	p "====================="
  	if @broker_name == "Others"
	  	respond_to do |format|
		    format.js { render :action => "populate_other_broker"}
		end
	end
  end

  def daily_calling_report
  	if params[:from]==nil && params[:to] == nil
  		@from = DateTime.now.beginning_of_month
  		@to = DateTime.now
  	else
  		@from = params[:from]
  		@to = params[:to]
  	end
  	# @qualified_lead_called = 0
  	# @isv_lead_called = 0
  	# @ov_lead_called = 0
  	@executives=selections(Personnel, :name)
  	if params[:personnel_id] == nil
  		@current_executive = current_personnel.id
  	else
  		@current_executive = params[:personnel_id].to_i
		@fresh_leads = []
		fresh_followups = FollowUp.where(first: true, personnel_id: @current_executive).where('communication_time >= ? AND communication_time <= ?', @from.to_datetime, @to.to_datetime)
		fresh_followups.each do |followup|
			@fresh_leads += [followup.lead]
		end
		@fresh_leads = @fresh_leads.uniq
		@followup_leads = []
		FollowUp.where(personnel_id: @current_executive).where('communication_time >= ? AND communication_time <= ?', @from.to_datetime.beginning_of_day, @to.to_datetime.end_of_day).each do |followup|
			# if followup.lead.visit_organised_on == nil
			# 	if followup.lead.interested_in_site_visit_on == nil
			# 		if followup.lead.qualified_on == nil
			# 		else
			# 			if followup.lead.qualified_on.to_date < DateTime.now.to_date
			# 				@qualified_lead_called += 1
			# 			end
			# 		end
			# 	else
			# 		if followup.lead.interested_in_site_visit_on.to_date < DateTime.now.to_date
			# 			@isv_lead_called += 1
			# 		end
			# 	end
			# else
			# 	if followup.lead.visit_organised_on.to_date < DateTime.now.to_date
			# 		@ov_lead_called += 1
			# 	end
			# end
			@followup_leads += [followup.lead]
		end
		@followup_leads = @followup_leads.uniq
  	end
  end

  def export_daily_calling_report
  	@current_executive = params[:current_executive].to_i
  	@from = params[:from]
  	@to = params[:to]
  	@fresh_leads = []
	fresh_followups = FollowUp.where(first: true, personnel_id: @current_executive).where('communication_time >= ? AND communication_time <= ?', @from.to_datetime, @to.to_datetime)
	fresh_followups.each do |followup|
		@fresh_leads += [followup.lead]
	end
	@fresh_leads = @fresh_leads.uniq
	@followup_leads = []
	FollowUp.where(personnel_id: @current_executive).where('communication_time >= ? AND communication_time <= ?', @from.to_datetime, @to.to_datetime).each do |followup|
		@followup_leads += [followup.lead]
	end
	@followup_leads = @followup_leads.uniq
    respond_to do |format|
        format.xls
    end
  end

  def reengaged_lead_index
  	executives=Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ?', nil, 2)
	@executives=[["All Executives", -1]]
	executives.each do |executive|
		@executives+=[[executive.name, executive.id]]
	end
	@executives.sort!
  	if request.get?
  		@leads = Lead.where(personnel_id: current_personnel.id, booked_on: nil, lost_reason_id: nil).where.not(reengaged_on: nil)
  		@executive = current_personnel.id
  	elsif params[:commit] == "Refresh"
  		if params[:executive_id].to_i == -1
  			@executive = -1
	  		@leads = Lead.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}, booked_on: nil, lost_reason_id: nil).where.not(reengaged_on: nil)
  		else
	  		personnel = Personnel.find(params[:executive_id].to_i)
	  		@executive = params[:executive_id].to_i
	  		@leads = Lead.where(personnel_id: personnel.id, booked_on: nil, lost_reason_id: nil).where.not(reengaged_on: nil)
	  	end
  	else
  		redirect_to :controller => "windows", :action => "followup_history", :id => (params.select{|key, value| value == ">" }.keys[0])		
  	end
  end

  def export_all_live_leads
  	data = params[:value]
  	position_1 = data.index("*")
  	position_2 = data.index("%")
  	position_3 = data.index("$")
  	position_4 = data.index("#")
  	position_5 = data.index("^")
  	position_6 = data.index("&")
  	since = data[position_1+1..position_2-1]
  	qualified = data[position_2+1..position_3-1]
  	interested = data[position_3+1..position_4-1]
  	site_visited = data[position_4+1..position_5-1]
  	executive = data[position_5+1..position_6-1].to_i
  	selected_business_unit_id = data[position_6+1..data.length].to_i
  	if site_visited == "" && interested == ""
		# qualified
		if executive == -1
			@leads=Lead.where(business_unit_id: selected_business_unit_id, booked_on: nil, interested_in_site_visit_on: nil, site_visited_on: nil).where.not(qualified_on: nil).where('leads.generated_on >= ?', since.to_datetime)
		else
			@leads = Personnel.find(executive).all_qualified_leads
		end
	elsif site_visited == "" && qualified == "" 
		#interested in site_visit
		if executive == -1
			@leads=Lead.where(business_unit_id: selected_business_unit_id, booked_on: nil, site_visited_on: nil, visit_organised_on: nil).where.not(interested_in_site_visit_on: nil).where('leads.generated_on >= ?', since.to_datetime)
		else
			@leads = Personnel.find(executive).all_interested_leads
		end
	elsif qualified == "" && interested == ""
		# site visited
		if executive==-1
			executives = Personnel.where(business_unit_id: @selected_business_unit_id).pluck(:id)
			@leads=[]
			executives.each do |selected_executive|
				@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => selected_executive}).where.not(:leads => {site_visited_on: nil})
				@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => selected_executive}).where.not(:leads => {site_visited_on: nil})
			end
		else
	    	@leads = Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time <= ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil})
			@leads += Lead.includes(:follow_ups, :source_category, :business_unit, :personnel).where( :follow_ups => { :last => true } ).where('follow_ups.follow_up_time > ?', Date.today+1.day).where('leads.status is ? OR leads.status = ?', nil, false).where(:leads => { :personnel_id => executive}).where.not(:leads => {site_visited_on: nil}) 					
		end
	else
		if executive == -1
			@leads = Lead.where(business_unit_id: selected_business_unit_id, booked_on: nil, interested_in_site_visit_on: nil, site_visited_on: nil).where.not(qualified_on: nil).where('leads.generated_on >= ?', since.to_datetime)
			@leads += Lead.where(business_unit_id: selected_business_unit_id, booked_on: nil, site_visited_on: nil, visit_organised_on: nil).where.not(interested_in_site_visit_on: nil).where('leads.generated_on >= ?', since.to_datetime)
		else
			@leads = Personnel.find(executive).all_qualified_leads
			@leads += Personnel.find(executive).all_interested_leads
		end
	end	
    respond_to do |format|
        format.xls
    end
  end

  def import_costing_report

  end

  def costing_report_import
 	year=params[:date][:year].to_i
	month=params[:date][:month].to_i
	beginning_of_month = DateTime.new(year, month, 1)
	errors = Expenditure.import([params[:file], beginning_of_month])
	if errors.count > 0
		flash[:danger]="Costing Report imported with error-"+errors.count.to_s
	else	
		flash[:success]="Costing Report imported!"
	end
	redirect_to windows_facebook_costing_report_url	
  end

  def facebook_costing_report
  	@projects=selections_with_all(BusinessUnit, :name)
  	@from=(Date.today)-30
  	@to=(Date.today)
  	if params[:lead] != nil
    	@from=params[:lead][:from]
    	@to=params[:lead][:to]
  	end
	@sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
	@projects=selections_with_all(BusinessUnit, :name)
	if params[:project]==nil
		project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
		@business_unit_id = "-1"
	else
		if params[:project][:selected] == "-1"
			project_selected=BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
			@business_unit_id = "-1"
		else
			project_selected=params[:project][:selected]
			@business_unit_id=project_selected
		end
	end
	
	if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Marketing' || current_personnel.status=='Team Lead'
		@site_executives=selections_with_all_active(Personnel, :name)
		if params[:site_executive]==nil
			@executive=-1
		elsif params[:site_executive][:picked]==-1
			@executive=-1
		else
			@executive=params[:site_executive][:picked].to_i	
		end
		if @executive==-1	
			@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		else
			@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
			@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
			@site_visited=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@booked=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
			@leads_lost=Lead.includes(:personnel).where(:personnels => {id: @executive}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		end		
	else
		@leads_generated_raw=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
		@leads_generated=@leads_generated_raw.group("leads.source_category_id").count
		@site_visited=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@booked=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
		@leads_lost=Lead.includes(:personnel).where(:personnels => {id: current_personnel.id}, business_unit: project_selected, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
	end
	@site_visited_from_leads_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id").count
	@booked_from_leads_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true).group("leads.source_category_id").count
	@lost_from_leads_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id").count
	@qualified_from_leads_generated=@leads_generated_raw.where.not(qualified_on: nil).group('leads.source_category_id').count
	@isv_from_leads_generated=@leads_generated_raw.where.not(interested_in_site_visit_on: nil).group('leads.source_category_id').count
	
	all_sources=@leads_generated.merge(@site_visited).merge(@booked).merge(@leads_lost)
	all_sources=all_sources.keys.uniq
	
	@source_tree={}
	successors=[]
	successor_chain=0
	all_sources.each do |source|
	  if @leads_generated[source]==nil
	    leads_generated=0
	  else
	    leads_generated=@leads_generated[source]
	  end
	  if @site_visited[source]==nil
	    site_visited=0
	  else
	    site_visited=@site_visited[source]
	  end
	  if @booked[source]==nil
	    booked=0
	  else
	    booked=@booked[source]
	  end
	  if @leads_lost[source]==nil
	    leads_lost=0
	  else
	    leads_lost=@leads_lost[source]
	  end
	  if @site_visited_from_leads_generated[source]==nil
	    site_visited_from_leads_generated=0
	  else
	    site_visited_from_leads_generated=@site_visited_from_leads_generated[source]
	  end
	  if @booked_from_leads_generated[source]==nil
	    booked_from_leads_generated=0
	  else
	    booked_from_leads_generated=@booked_from_leads_generated[source]
	  end
	  if @lost_from_leads_generated[source]==nil
	    lost_from_leads_generated=0
	  else
	    lost_from_leads_generated=@lost_from_leads_generated[source]
	  end
	  if @qualified_from_leads_generated[source]==nil
	  	qualified_leads_from_generated=0
	  else
	  	qualified_leads_from_generated=@qualified_from_leads_generated[source]
	  end
	  if @isv_from_leads_generated[source]==nil
	  	isv_leads_from_generated=0
	  else
	  	isv_leads_from_generated=@isv_from_leads_generated[source]
	  end

	  predecessor_id=@sources.find(source).predecessor
	  successors=[]
	  if predecessor_id==nil && @source_tree[source]==nil
	    @source_tree[source]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated,qualified_leads_from_generated,qualified_leads_from_generated,isv_leads_from_generated,isv_leads_from_generated]
	  elsif predecessor_id==nil
	  	@source_tree[source][1]=leads_generated
	  	@source_tree[source][4]=site_visited
	  	@source_tree[source][6]=booked
	  	@source_tree[source][8]=leads_lost
	  	@source_tree[source][10]=site_visited_from_leads_generated
	  	@source_tree[source][12]=booked_from_leads_generated
	  	@source_tree[source][14]=lost_from_leads_generated
	  	@source_tree[source][16]=qualified_leads_from_generated
	  	@source_tree[source][18]=isv_leads_from_generated
	  else
	    successors+=[source]
	    until predecessor_id==nil do
	      predecessor=@sources.find(predecessor_id) 
	      successors+=[predecessor_id]
	      predecessor_id=predecessor.predecessor
	    end
	    successors=successors.reverse
	    successor_chain=nil
	    @source=source
	    p source
	    p @source_tree
	    p '-----------'
	    successors.each do |successor|
	      if successor==successors.first
	        if @source_tree[successor]==nil
	          @source_tree[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]  
	        else
	          @source_tree[successor][0]=@source_tree[successor][0]+leads_generated
	          @source_tree[successor][3]=@source_tree[successor][3]+site_visited
	          @source_tree[successor][5]=@source_tree[successor][5]+booked
	          @source_tree[successor][7]=@source_tree[successor][7]+leads_lost
	          @source_tree[successor][9]=@source_tree[successor][9]+site_visited_from_leads_generated
	          @source_tree[successor][11]=@source_tree[successor][11]+booked_from_leads_generated
	          @source_tree[successor][13]=@source_tree[successor][13]+lost_from_leads_generated
	          @source_tree[successor][15]=@source_tree[successor][15]+qualified_leads_from_generated
	          p successor
	          p @source_tree
	          @source_tree[successor][17]=@source_tree[successor][17]+isv_leads_from_generated
	        end
	      successor_chain=@source_tree[successor][2]
	      else
	        if successor_chain[successor]==nil
	        	if successor==successors.last
	          		successor_chain[successor]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated, qualified_leads_from_generated, qualified_leads_from_generated, isv_leads_from_generated, isv_leads_from_generated]
	        	else
	        		successor_chain[successor]=[leads_generated,0,{},site_visited,0,booked,0,leads_lost,0,site_visited_from_leads_generated,0,booked_from_leads_generated,0,lost_from_leads_generated,0, qualified_leads_from_generated,0, isv_leads_from_generated,0]
	        	end
	        else
	          successor_chain[successor][0]=successor_chain[successor][0]+leads_generated
	          successor_chain[successor][3]=successor_chain[successor][3]+site_visited
	          successor_chain[successor][5]=successor_chain[successor][5]+booked
	          successor_chain[successor][7]=successor_chain[successor][7]+leads_lost
	          successor_chain[successor][9]=successor_chain[successor][9]+site_visited_from_leads_generated
	          successor_chain[successor][11]=successor_chain[successor][11]+booked_from_leads_generated
	          successor_chain[successor][13]=successor_chain[successor][13]+lost_from_leads_generated  
	          successor_chain[successor][15]=successor_chain[successor][15]+qualified_leads_from_generated  
	          successor_chain[successor][17]=successor_chain[successor][17]+isv_leads_from_generated  
	        end
	      successor_chain=successor_chain[successor][2]
	      end
	    end  
	  end
	end
	@source_tree=Hash[@source_tree.sort_by{|k, v| v[0]}.reverse]	
  end

  def populate_area_other
  	@area_type=params[:type]
    if @area_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_area_other"}
      end
    end
  end

  def populate_work_area_other
    @area_type=params[:type]
    if @area_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_work_area_other"}
      end
    end
  end

  def populate_occupation_other
    @occupation_type=params[:type]
    if @occupation_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_occupation_other"}
      end
    end
  end

  def customer_followup_entry
  	if params[:update] == 'Update'
  		if params[:lead] == nil
  			p params
  			p "=================="
	  		all_lead_ids = params[:lead_ids]
			all_lead_ids.each do |lead_id|
				Lead.find(lead_id).update(status: true, osv: nil, booked_on: params[:leading][:flexible_date], lost_reason_id: params[:leading][:lost_reason], customer_remarks: params[:followup_remarks])
			end

			redirect_to windows_fresh_leads_url	
		else
			redirect_to controller: 'windows', action: 'followup_entry', params: request.request_parameters 
		end
  	else
	  	if params["Allocate"] == nil
	  		if params[:call_1] == nil
				if params[:call_2] == nil
					if params[:call_other] == nil
						if params[:connected_call] == nil
						else
							call_btn = "connected call"
							lead_id = params[:connected_call].keys[0]
						end
					else
						call_btn = "third"
						lead_id = params[:call_other].keys[0]
					end
				else
					call_btn = "second"
					lead_id = params[:call_2].keys[0]
				end
			else
				call_btn = "first"
				lead_id = params[:call_1].keys[0]
			end
			if params[:id] == nil
		    	@lead = Lead.find(lead_id.to_i)
		    else
		    	@lead = Lead.find(params[:id].to_i)
		    end
		    if current_personnel.id == @lead.personnel_id
		    	if call_btn == "connected call"
		    		@telephony_call = nil
		    		@telephony_call = TelephonyCall.where(lead_id: params[:connected_call].keys[0].to_i, untagged: nil).sort_by{|x| x.created_at}.last
		    	else
		    		@lead.call_the_customer(call_btn)
		    	end
		    end
		    @gurukul_whatsapp_templates = ["gurukul_brochure_mobileview", "gurukul_location", "gurukul_project_brief"]
		    if current_personnel.name == 'Olivia De'
		    	@whatsapp_templates = WhatsappTemplate.where(business_unit_id: [5, 6], inactive: nil).map{|x| [x.title, x.id]}
		    else
		    	@whatsapp_templates = WhatsappTemplate.where(business_unit_id: current_personnel.business_unit_id, inactive: nil).map{|x| [x.title, x.id]}
		    end
			@email_templates=[]
			if current_personnel.mapped == nil || current_personnel.mapped == ""
				if current_personnel.status=='Admin' || current_personnel.status=='Back Office'	|| current_personnel.status=='Sales Executive'	|| current_personnel.status=='Team Lead' || current_personnel.status=='Marketing' || current_personnel.status == "Audit"
					executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
					@executives=[]
					executives.each do |executive|
						@executives+=[[executive.name, executive.id]]
					end
					@executives.sort!
				end
			else
				mapped_executive_id = [current_personnel.id]
				mapped_executive_id += [current_personnel.mapped]
				executives = Personnel.where(organisation_id: current_personnel.organisation_id, id: mapped_executive_id)
				@executives = []
				executives.each do |executive|
					@executives+=[[executive.name, executive.id]]
				end
				Personnel.where(organisation_id: current_personnel.organisation_id, access_right: 2, expanded: true).each do |personnel|
					if personnel.id == current_personnel.id
					else
						@executives+=[[personnel.name, personnel.id]]
					end
				end
				@executives.sort!
			end
		    @lost_reasons=selections(LostReason, :description)  
		    @common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
		    @age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
		    @areas = selections_with_other(Area, :name).sort
		    @occupations=selections_with_other(Occupation, :description).sort
		    WhatsappTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |whatsapp_template|
		      @whatsapp_templates+=[[whatsapp_template.title, whatsapp_template.id]]
		    end
		    EmailTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |email_template|
		      @email_templates+=[[email_template.title, email_template.id]]
		    end
		else
			all_leads = params[:lead_id]
			all_leads.each do |lead_id|
				Lead.find(lead_id).update(personnel_id: params[:site_executive][:picked].to_i)
				UserMailer.new_lead_notification(Lead.find(lead_id)).deliver
				# lead_for_sms = Lead.find(lead_id)
				# executive_number = '91'+lead_for_sms.personnel.mobile
				# if lead_for_sms.mobile != nil && lead_for_sms.email != nil
				# message="Source: "+lead_for_sms.source_category.description+', '+ lead_for_sms.name+", 0"+lead_for_sms.mobile+", "+lead_for_sms.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead_for_sms.id.to_s).short_url
				# elsif lead_for_sms.mobile != nil
				# message="Source: "+lead_for_sms.source_category.description+', '+ lead_for_sms.name+", 0"+lead_for_sms.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead_for_sms.id.to_s).short_url
				# elsif lead_for_sms.email != nil
				# message="Source: "+lead_for_sms.source_category.description+', '+ lead_for_sms.name+", "+lead_for_sms.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead_for_sms.id.to_s).short_url
				# end	
				# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+lead_for_sms.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
				# response=HTTParty.get(urlstring)
			end
			redirect_to :back
		end
	end
  end

  def qualified_leads_register
  	@lead_types = ['All', 'Qualified Live', 'Qualified Lost', 'Site Visited Live', 'Site Visited Lost', 'Booked']
  	@projects=selections(BusinessUnit, :name)
  	if params[:business_unit_id] == nil
  		@project_selected = '2'
  		@lead_type = 'All'
  		@from = DateTime.now-7.days
  		@to = DateTime.now
  		@leads = Lead.where(business_unit_id: 2).where('qualified_on is not ?', nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
  	else
  		@project_selected = params[:business_unit_id].to_i
  		@lead_type = params[:lead_type]
  		@from = params[:from].to_datetime
  		@to = params[:to].to_datetime
  		@actual_leads = []
  		@absolute = params[:absolute]
  		if params[:absolute] == nil
	  		if @lead_type == 'All'
	  			@leads = Lead.where(business_unit_id: @project_selected).where('qualified_on is not ?', nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
	  		elsif @lead_type == 'Qualified Live'
	  			@leads = Lead.where(business_unit_id: @project_selected, lost_reason_id: nil, booked_on: nil, site_visited_on: nil).where('qualified_on is not ?', nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Qualified Lost'
				@leads = Lead.where(business_unit_id: @project_selected).where.not(lost_reason_id: nil, booked_on: nil).where('qualified_on is not ?', nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Site Visited Live'
				@leads = Lead.where(business_unit_id: @project_selected, lost_reason_id: nil, booked_on: nil).where.not(site_visited_on: nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Site Visited Lost'
				@leads = Lead.where(business_unit_id: @project_selected).where.not(lost_reason_id: nil, booked_on: nil, site_visited_on: nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Booked'
				@leads = Lead.where(business_unit_id: @project_selected, lost_reason_id: nil).where.not(booked_on: nil).where('generated_on >= ? AND generated_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			end
		else
			if @lead_type == 'All'
	  			@leads = Lead.where(business_unit_id: @project_selected).where('qualified_on >= ? AND qualified_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
	  		elsif @lead_type == 'Qualified Live'
	  			@leads = Lead.where(business_unit_id: @project_selected, lost_reason_id: nil, booked_on: nil, site_visited_on: nil).where('qualified_on >= ? AND qualified_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Qualified Lost'
				@leads = Lead.where(business_unit_id: @project_selected).where.not(lost_reason_id: nil, booked_on: nil).where('qualified_on >= ? AND qualified_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Site Visited Live'
				@leads = Lead.where(business_unit_id: @project_selected, lost_reason_id: nil, booked_on: nil).where.not(site_visited_on: nil).where('qualified_on >= ? AND qualified_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Site Visited Lost'
				@leads = Lead.where(business_unit_id: @project_selected).where.not(lost_reason_id: nil, booked_on: nil, site_visited_on: nil).where('qualified_on >= ? AND qualified_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			elsif @lead_type == 'Booked'
				@leads = Lead.where(business_unit_id: @project_selected, lost_reason_id: nil).where.not(booked_on: nil).where('qualified_on >= ? AND qualified_on < ?', @from.beginning_of_day-5.hours-30.minutes, @to.beginning_of_day-5.hours-30.minutes+1.day)
			end
		end
  	end
  end

  def booking_date_edit
  	@lead = Lead.find(params[:format])
  end

  def booking_date_update
  	lead = Lead.find(params[:lead_id])
  	if params[:cancellation_date] == nil || params[:cancellation_date] == ""
  		lead.update(booked_on: params[:booking][:date])
  	else
  		lead.update(booked_on: params[:booking][:date], cancelled_on: params[:cancellation_date])
  	end

  	flash[:success] = "Booking date updated successfully."
  	redirect_to windows_booked_leads_url
  end

  def sv_personnel_detail_form
  	if params[:format] == nil 
  		if params[:source_category_id] == nil
	  		@source_category = ""
	  	else
	  		@source_category = SourceCategory.find(params[:source_category_id])
	  	end
	  	if params[:broker_lead_intimation] == nil
	  		p "inserting into the if section"
	  		@broker_lead_intimation = nil
	  	else
	  		p "inserting into the else section"
	  		@broker_lead_intimation = BrokerLeadIntimation.find(params[:broker_lead_intimation].to_i)
	  		@source_category = SourceCategory.find(params[:source_category_id])
	  	end
  	else
  		if params[:page_name] == nil
  			@lead = Lead.find(params[:format])
  		else
  			@broker_lead_intimation = BrokerLeadIntimation.find(params[:broker_lead_intimation].to_i)
  		end
	end
  end

  def sv_personnel_details_submit
  	redirect_to controller: 'windows', action: 'sv_office_details_form', params: request.request_parameters
  end
  def sv_office_details_form
  	@occupations=selections(Occupation, :description)
  	@designations=selections(Designation, :description)
  	if params[:existing_lead] == nil
  	else
  		@lead = Lead.find(params[:existing_lead].to_i)
  	end
  end
  def sv_office_details_submit
  	redirect_to controller: 'windows', action: 'sv_requirement_form', params: request.request_parameters
  end
  def sv_requirement_form
  	if params[:existing_lead] == nil
  	else
  		@lead = Lead.find(params[:existing_lead].to_i)
  	end
  end
  def sv_requirement_form_submit
  	if params[:existing_lead] == nil
	  	lead = Lead.new
	  	lead.name = params[:lead][:name]
	  	lead.status=false
	  	lead.email = params[:lead][:email]
	  	lead.mobile = params[:lead][:mobile]
	  	lead.address = params[:lead][:address]
	  	lead.age_bracket = params[:dob]
	  	lead.company = params[:lead][:company]
	  	lead.pincode = params[:lead][:pincode]
	  	lead.site_visited_on = DateTime.now
	  	lead.qualified_on = DateTime.now
	  	lead.interested_in_site_visit_on = DateTime.now
	  	lead.business_unit_id = current_personnel.business_unit_id
	  	if params[:source_category_id] == nil || params[:source_category_id] == ""
	  		lead.source_category_id = 592
	  	else
	  		lead.source_category_id = params[:source_category_id].to_i
	  	end
	  	lead.personnel_id = current_personnel.id
	  	lead.work_address = params[:lead][:work_address]
	  	p params[:lead][:office_pincode]
	  	p "=============================="
	  	lead.office_pincode = params[:lead][:office_pincode].to_s
	  	lead.generated_on = DateTime.now
	  	lead.save
	  	if params[:lead][:occupation_id] == "-1"
	  		# occupation = Occupation.new
	  		# occupation.description = params[:occupation][:other]
	  		# occupation.organisation_id = current_personnel.organisation_id
	  		# occupation.save
	  		# lead.update(occupation_id: occupation.id)
	  	else
	  		lead.update(occupation_id: params[:lead][:occupation_id])
	  	end
	  	if params[:lead][:designation_id] == "-1"
	  		# designation = Designation.new
	  		# designation.description = params[:designation][:other]
	  		# designation.organisation_id = current_personnel.organisation_id
	  		# designation.save
	  		# lead.update(designation_id: designation.id)
	  	else
	  		lead.update(designation_id: params[:lead][:designation_id])
	  	end
	  	if params[:purchasing_type] == nil
	  		lead.update(investment: nil)
	  	elsif params[:purchasing_type] == "investment"
	  		lead.update(investment: true)
	  	elsif params[:purchasing_type] == "residential"
	  		lead.update(investment: false)
	  	end
	  	if params[:other_project] == ""
	  	else
	  		other_project = OtherProject.new
	  		other_project.name = params[:other_project]
	  		other_project.organisation_id = current_personnel.organisation_id
	  		other_project.save

			other_project_tag = OtherProjectTag.new
			other_project_tag.other_project_id = other_project.id
			other_project_tag.lead_id = lead.id
			other_project_tag.save
	  	end
	  	if params[:flat_type] == nil
	  	else
	  		if params[:flat_type] == "1 BHK"
	  			lead.update(flat_type: 1)
	  		elsif params[:flat_type] == "2 BHK"
	  			lead.update(flat_type: 2)
			elsif params[:flat_type] == "3 BHK"
				lead.update(flat_type: 3)
			elsif params[:flat_type] == "4 BHK"
				lead.update(flat_type: 4)
			elsif params[:flat_type] == "5 BHK"
				lead.update(flat_type: 5)
			end
	  	end
	  	if params[:budget] == nil
	  	else
	  		if params[:budget] == "60-80 L"
	  			lead.update(budget_from: 60, budget_to: 80)
	  		elsif params[:budget] == "80 L-1 Cr"
	  			lead.update(budget_from: 80, budget_to: 1)
			elsif params[:budget] == "1-1.5 Cr"
				lead.update(budget_from: 1, budget_to: 2)
			elsif params[:budget] == "Above 1.5 Cr"
				lead.update(budget_from: 2, budget_to: 3)
			end
	  	end
	  	if params[:how_long] == nil
	  	else
	  		if params[:how_long] == "1 Month"
	  			lead.update(searching_since: "1 Month")
	  		elsif params[:how_long] == "3 Month"
	  			lead.update(searching_since: "3 Month")
			elsif params[:how_long] == "6 Month"
				lead.update(searching_since: "6 Month")
			elsif params[:how_long] == "More than that"
				lead.update(searching_since: "More than 6 month")
			end
	  	end
	  	if params[:signature_data] == ""
	  	else
	  		signature_data = params[:signature_data]
	  		lead.update(sv_form_signature: signature_data)
		end
		if params[:broker_lead_intimation] == "" || params[:broker_lead_intimation] == nil
		else
			BrokerLeadIntimation.find(params[:broker_lead_intimation].to_i).update(lead_id: lead.id)
			lead.update(personnel_id: 294)
			broker_contact = BrokerContact.find(BrokerLeadIntimation.find(params[:broker_lead_intimation].to_i).broker_contact_id)
			if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                else
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			        result = HTTParty.post(urlstring,
			        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
			        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                end
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		        result = HTTParty.post(urlstring,
		        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
		        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            else
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		        result = HTTParty.post(urlstring,
		        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
		        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                else
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			        result = HTTParty.post(urlstring,
			        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
			        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                end
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		        result = HTTParty.post(urlstring,
		        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
		        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            end
		end
	  	flash[:success] = "Form submited successfully."
	else
		lead = Lead.find(params[:existing_lead].to_i)
	  	lead.update(status: false, osv: nil, name: params[:lead][:name], email: params[:lead][:email], mobile: params[:lead][:mobile], company: params[:lead][:company], pincode: params[:lead][:pincode], office_pincode: params[:lead][:office_pincode], address: params[:lead][:address], work_address: params[:lead][:work_address], site_visited_on: DateTime.now, age_bracket: params[:dob])
	  	if params[:lead][:occupation_id] == "-1"
	  		# occupation = Occupation.new
	  		# occupation.description = params[:occupation][:other]
	  		# occupation.organisation_id = current_personnel.organisation_id
	  		# occupation.save
	  		# lead.update(occupation_id: occupation.id)
	  	else
	  		lead.update(occupation_id: params[:lead][:occupation_id])
	  	end
	  	if params[:lead][:designation_id] == "-1"
	  		# designation = Designation.new
	  		# designation.description = params[:designation][:other]
	  		# designation.organisation_id = current_personnel.organisation_id
	  		# designation.save
	  		# lead.update(designation_id: designation.id)
	  	else
	  		lead.update(designation_id: params[:lead][:designation_id])
	  	end
	  	if params[:purchasing_type] == nil
	  		lead.update(investment: nil)
	  	elsif params[:purchasing_type] == "investment"
	  		lead.update(investment: true)
	  	elsif params[:purchasing_type] == "residential"
	  		lead.update(investment: false)
	  	end
	  	if params[:other_project] == ""
	  	else
	  		other_project = OtherProject.new
	  		other_project.name = params[:other_project]
	  		other_project.organisation_id = current_personnel.organisation_id
	  		other_project.save

			other_project_tag = OtherProjectTag.new
			other_project_tag.other_project_id = other_project.id
			other_project_tag.lead_id = lead.id
			other_project_tag.save
	  	end
	  	if params[:flat_type] == nil
	  	else
	  		if params[:flat_type] == "1 BHK"
	  			lead.update(flat_type: 1)
	  		elsif params[:flat_type] == "2 BHK"
	  			lead.update(flat_type: 2)
			elsif params[:flat_type] == "3 BHK"
				lead.update(flat_type: 3)
			elsif params[:flat_type] == "4 BHK"
				lead.update(flat_type: 4)
			elsif params[:flat_type] == "5 BHK"
				lead.update(flat_type: 5)
			end
	  	end
	  	if params[:budget] == nil
	  	else
	  		if params[:budget] == "60-80 L"
	  			lead.update(budget_from: 60, budget_to: 80)
	  		elsif params[:budget] == "80 L-1 Cr"
	  			lead.update(budget_from: 80, budget_to: 1)
			elsif params[:budget] == "1-1.5 Cr"
				lead.update(budget_from: 1, budget_to: 2)
			elsif params[:budget] == "Above 1.5 Cr"
				lead.update(budget_from: 2, budget_to: 3)
			end
	  	end
	  	if params[:how_long] == nil
	  	else
	  		if params[:how_long] == "1 Month"
	  			lead.update(searching_since: "1 Month")
	  		elsif params[:how_long] == "3 Month"
	  			lead.update(searching_since: "3 Month")
			elsif params[:how_long] == "6 Month"
				lead.update(searching_since: "6 Month")
			elsif params[:how_long] == "More than that"
				lead.update(searching_since: "More than 6 month")
			end
	  	end
	  	if params[:signature_data] == ""
	  	else
	  		signature_data = params[:signature_data]
	  		lead.update(sv_form_signature: signature_data)
		end
		if params[:broker_lead_intimation] == "" || params[:broker_lead_intimation] == nil
		else
			broker_lead_intimation = BrokerLeadIntimation.find(params[:broker_lead_intimation].to_i)
			broker_lead_intimation.update(lead_id: lead.id)
			broker_contact = BrokerContact.find(broker_lead_intimation.broker_contact_id)
			if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                else
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			        result = HTTParty.post(urlstring,
			        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
			        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                end
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		        result = HTTParty.post(urlstring,
		        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": broker_lead_intimation.name}]}]}}.to_json,
		        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            else
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		        result = HTTParty.post(urlstring,
		        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
		        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                else
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			        result = HTTParty.post(urlstring,
			        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": lead.name}]}]}}.to_json,
			        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                end
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		        result = HTTParty.post(urlstring,
		        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_visit_thanks", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": broker_lead_intimation.name}]}]}}.to_json,
		        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            end
		end
		flash[:success] = "Form submited successfully."
	end
  	redirect_to windows_sv_form_index_url
  end

  def customer_feedback_form
  	@lead = Lead.find(params[:format])
  end

  def customer_feedback_entry
  	lead = Lead.find(params[:lead_id].to_s)
  	lead.update(hospitality_rating: params[:hospitality_rating], site_executive_rating: params[:site_executive_rating], project_explanation_rating: params[:project_explanation_rating], cleanliness_rating: params[:cleanliness_rating], jain_group_rating: params[:jain_group_rating], quality_conscious_rating: params[:quality_conscious_rating], customer_feedback: params[:customer_feedback])
    p params[:hospitality_rating]
    p'===================='
    p params[:site_executive_rating]
    p"================================"
    p params[:project_explanation_rating]
    p"============================="
    p params[:cleanliness_rating]
    p"==============================="
    p params[:jain_group_rating]
    p"==========================="
    p params[:quality_conscious_rating]
    p"================================"
    p params[:customer_feedback]
    p"======================done===============" 

  	flash[:success] = 'Thanks for your valuable Feedback.'
  	if current_personnel
  		redirect_to windows_sv_form_index_url
  	else
  		redirect_to broker_setup_thank_you_url
  	end
  end

  def customer_feedback_report
  	@projects = selections_with_all(BusinessUnit, :name)
    if params[:business_unit_id] == nil
      @project_selected = BusinessUnit.where(organisation_id: current_personnel.organisation_id).pluck(:id)
      @from = DateTime.now-10.days
      @to = DateTime.now
      @leads = []
    else
      @project_selected = params[:business_unit_id]
      @from = params[:from].to_datetime
      @to = params[:to].to_datetime
      @leads = Lead.where(business_unit_id: @project_selected.to_i).where('site_visited_on >= ? AND site_visited_on < ?', @from.beginning_of_day, @to.beginning_of_day+1.day)
    end
  end

  def populate_rating_reason
  	@rating = params[:rating]
  	respond_to do |format|
	    format.js { render :action => "populate_rating_reason"}
	end	
  end

  	def reply_to_customer_over_whatsapp
  		@gurukul_whatsapp_templates = ["gurukul_location", "gurukul_project_brief", "dream_gurukul_brochure", "60days_contract_signing", "broker_lead_intimation"]
		if params[:reply_to_customer] == nil && params[:other_details] == nil
		else
			customer_number = params[:customer_number]
			whatsapp_number = params[:whatsapp_number]
			broker_contact = nil
			broker_contacts = BrokerContact.where('mobile_one = ? OR mobile_two = ?', customer_number[2..customer_number.length], customer_number[2..customer_number.length])
			if broker_contacts == []
			else
				if broker_contacts.count == 1
					broker_contact  = broker_contacts[0]
				end
			end
			if broker_contact == nil
			else
				if params[:other_details] == nil
					reply = params[:reply_to_customer]
					urlstring = "https://graph.facebook.com/v17.0/132619236591729/messages"
					result = HTTParty.post(urlstring,
					:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => reply.to_s}}.to_json,
					:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
					p result
					p "===================="
					data = [customer_number, whatsapp_number, reply]
			  		UserMailer.sending_whatsapp_to_customer(data).deliver
					message_data = result.parsed_response
				  	message_id = message_data["messages"]
				  	message_id = message_id[0]["id"]
		  			whatsapp_followup = WhatsappFollowup.new
					whatsapp_followup.broker_contact_id = broker_contact.id
					whatsapp_followup.bot_message = "Agent Reply: "+reply.to_s
					whatsapp_followup.message_id = message_id
					whatsapp_followup.save
				else
					if params[:reply_to_customer] == ""
						params[:whatsapp_templates].each do |whatsapp_template_name|
			                if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
			                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
			                    else
			                        if whatsapp_template_name == "dream_gurukul_brochure"
			                            link_text = ""
			                            if broker_contact.email == nil || broker_contact.email == ""
			                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_two.to_s
			                            else
			                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_two.to_s
			                            end
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        elsif whatsapp_template_name == "60days_contract_signing" 
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        elsif whatsapp_template_name == "broker_lead_intimation"
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        else
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            p result
			                            p "============project details result===================="
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        end
			                    end
			                else
			                    if whatsapp_template_name == "dream_gurukul_brochure"
			                        link_text = ""
			                        if broker_contact.email == nil || broker_contact.email == ""
			                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_one.to_s
			                        else
			                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_one.to_s
			                        end
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                    elsif whatsapp_template_name == "60days_contract_signing" 
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                    elsif whatsapp_template_name == "broker_lead_intimation"
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                    else
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                        p result
			                        p "============project details result===================="
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
			                        else 
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            p result
			                            p "============project details result===================="
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        end
			                    end
			                end
			            end
					else
						reply = params[:reply_to_customer]
						urlstring = "https://graph.facebook.com/v17.0/132619236591729/messages"
						result = HTTParty.post(urlstring,
						:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => reply.to_s}}.to_json,
						:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
						p result
						p "===================="
						data = [customer_number, whatsapp_number, reply]
				  		UserMailer.sending_whatsapp_to_customer(data).deliver
				  		message_data = result.parsed_response
					  	message_id = message_data["messages"]
					  	message_id = message_id[0]["id"]
			  			whatsapp_followup = WhatsappFollowup.new
						whatsapp_followup.broker_contact_id = broker_contact.id
						whatsapp_followup.bot_message = "Agent Reply: "+reply.to_s
						whatsapp_followup.message_id = message_id
						whatsapp_followup.save
					
						params[:whatsapp_templates].each do |whatsapp_template_name|
			                if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
			                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
			                    else
			                        if whatsapp_template_name == "dream_gurukul_brochure"
			                            link_text = ""
			                            if broker_contact.email == nil || broker_contact.email == ""
			                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_two.to_s
			                            else
			                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_two.to_s
			                            end
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        elsif whatsapp_template_name == "60days_contract_signing" 
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        elsif whatsapp_template_name == "broker_lead_intimation"
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        else
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            p result
			                            p "============project details result===================="
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        end
			                    end
			                else
			                    if whatsapp_template_name == "dream_gurukul_brochure"
			                        link_text = ""
			                        if broker_contact.email == nil || broker_contact.email == ""
			                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_one.to_s
			                        else
			                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_one.to_s
			                        end
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                    elsif whatsapp_template_name == "60days_contract_signing" 
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                    elsif whatsapp_template_name == "broker_lead_intimation"
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                    else
			                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                        result = HTTParty.post(urlstring,
			                        :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
			                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                        p result
			                        p "============project details result===================="
			                        whatsapp_followup = WhatsappFollowup.new
			                        whatsapp_followup.broker_contact_id = broker_contact.id
			                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                        message_data = result.parsed_response
			                        message_id = message_data["messages"]
			                        message_id = message_id[0]["id"]
			                        whatsapp_followup.message_id = message_id
			                        whatsapp_followup.save
			                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
			                        else 
			                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                            result = HTTParty.post(urlstring,
			                            :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
			                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                            p result
			                            p "============project details result===================="
			                            whatsapp_followup = WhatsappFollowup.new
			                            whatsapp_followup.broker_contact_id = broker_contact.id
			                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
			                            message_data = result.parsed_response
			                            message_id = message_data["messages"]
			                            message_id = message_id[0]["id"]
			                            whatsapp_followup.message_id = message_id
			                            whatsapp_followup.save
			                        end
			                    end
			                end
			            end
					end
				end
			end

	  		flash[:success] = "whatsapp sent successfully."
	  		redirect_to :back
		end
	end

	def conversation_history
		@lead = Lead.find(params[:format])
	end

	def sv_feedback_link_send
		lead = Lead.find(params[:format])
		if lead.email == nil || lead.email == ""
		else
			UserMailer.sv_feedback_link_send([lead]).deliver
		end
		if lead.mobile == nil || lead.mobile == ""
		else
			urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		    result = HTTParty.post(urlstring,
		    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+lead.mobile.to_s, "type": "template", "template": {"name": "sv_feedback_link","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": lead.name}, {"type": "text","text": lead.business_unit.name}]}, {"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": lead.id.to_s}]}]}}.to_json,
		    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
		    p result
		    p "======================="
		end
		flash["success"] = "Feedback Link Send successfully."
		redirect_to windows_sv_form_index_url
	end

  	private
	  def payment_milestone_params
	    params.require(:payment_milestone).permit(:description, :block_level, :floor_level)
	  end

	  def require_login
	      unless current_personnel
	        p request.original_url
	      	redirect_to :controller => "sessions", :action => "new", :original_url => request.original_url
	      	
	        # redirect_to log_in_path, alert: "You need to log in to access this page.", :original_url => request.original_url
	      end
	  end
end