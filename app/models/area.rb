class Area < ApplicationRecord
	def self.area_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(area_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(area_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads_count = unselected_leads.count
		unselected_qualified = 0
		unselected_site_visit = 0
		unselected_booked = 0
		unselected_leads.each do |lead|
			if lead.qualified_on != nil
				unselected_qualified += 1
			end
			if lead.osv==nil && lead.status==false
				unselected_site_visit += 1
			elsif lead.status==true && lead.lost_reason_id==nil
				unselected_booked += 1
			end	
		end
		all_areas=[]
		area_data={}
		Area.where(organisation_id: current_personnel.organisation_id).each do |area|
			all_leads.each do |lead|
				if lead.area_id == area.id
					if area_data[area.name] == nil
						area_data[area.name] = 1
					else
						area_data[area.name] = area_data[area.name]+1
					end
					if lead.qualified_on != nil
						if area_data["qualified"] == nil
							area_data["qualified"] = 1
						else
							area_data["qualified"] = area_data["qualified"].to_i+1
						end
					else
						area_data["qualified"] = 0
					end
					if lead.osv==nil && lead.status==false
						if area_data["site visit"]==nil
							area_data["site visit"]=1
						else
							area_data["site visit"] = area_data["site visit"].to_i+1
						end
						area_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						area_data["site visit"]=''
						if area_data["booked"]==nil
							area_data["booked"]=1
						else
							area_data["booked"]=area_data["booked"].to_i+1
						end
					else
						area_data["site visit"]=''
						area_data["booked"]=''
					end
				end	
			end
			all_areas += [area_data]
			area_data={}
		end
		data=[all_areas, unselected_leads_count, unselected_qualified, unselected_site_visit, unselected_booked]
		
		return data
	end

	def self.work_area_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(work_area_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(work_area_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads_count = unselected_leads.count
		unselected_qualified = 0
		unselected_site_visit = 0
		unselected_booked = 0
		unselected_leads.each do |lead|
			if lead.qualified_on != nil
				unselected_qualified += 1
			end
			if lead.osv==nil && lead.status==false
				unselected_site_visit += 1
			elsif lead.status==true && lead.lost_reason_id==nil
				unselected_booked += 1
			end	
		end
		all_work_areas=[]
		work_area_data={}
		Area.where(organisation_id: current_personnel.organisation_id).each do |work_area|
			all_leads.each do |lead|
				if lead.work_area_id == work_area.id
					if work_area_data[work_area.name]==nil
						work_area_data[work_area.name]=1
					else
						work_area_data[work_area.name]=work_area_data[work_area.name]+1
					end
					if lead.qualified_on != nil
						if work_area_data["qualified"] == nil
							work_area_data["qualified"] = 1
						else
							work_area_data["qualified"] = work_area_data["qualified"].to_i+1
						end
					else
						work_area_data["qualified"] = 0
					end
					if lead.osv==nil && lead.status==false
						if work_area_data["site visit"]==nil
							work_area_data["site visit"]=1
						else
							work_area_data["site visit"] = work_area_data["site visit"].to_i+1
						end
						work_area_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						work_area_data["site visit"]=''
						if work_area_data["booked"]==nil
							work_area_data["booked"]=1
						else
							work_area_data["booked"]=work_area_data["booked"].to_i+1
						end
					else
						work_area_data["site visit"]=''
						work_area_data["booked"]=''
					end
				end	
			end
			all_work_areas += [work_area_data]
			work_area_data={}
		end
		data=[all_work_areas, unselected_leads_count, unselected_qualified, unselected_site_visit, unselected_booked]
		
		return data
	end
end
