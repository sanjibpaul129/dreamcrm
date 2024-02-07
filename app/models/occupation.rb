class Occupation < ApplicationRecord
	def self.occupation_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(occupation_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(occupation_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
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
		all_occupations=[]
		occupation_data={}
		Occupation.where(organisation_id: current_personnel.organisation_id).each do |occupation|
			all_leads.each do |lead|
				if lead.occupation_id == occupation.id
					if occupation_data[occupation.description]==nil
						occupation_data[occupation.description]=1
					else
						occupation_data[occupation.description]=occupation_data[occupation.description]+1
					end
					if lead.qualified_on != nil
						if occupation_data["qualified"] == nil
							occupation_data["qualified"] = 1
						else
							occupation_data["qualified"] = occupation_data["qualified"].to_i+1
						end
					end
					if lead.osv==nil && lead.status==false
						if occupation_data["site visit"]==nil
							occupation_data["site visit"]=1
						else
							occupation_data["site visit"] = occupation_data["site visit"].to_i+1
						end
						occupation_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						occupation_data["site visit"]=''
						if occupation_data["booked"]==nil
							occupation_data["booked"]=1
						else
							occupation_data["booked"]=occupation_data["booked"].to_i+1
						end
					else
						occupation_data["site visit"]=''
						occupation_data["booked"]=''
					end
				end	
			end
			all_occupations += [occupation_data]
			occupation_data = {}
		end
		data = [all_occupations, unselected_leads_count, unselected_qualified, unselected_site_visit, unselected_booked]
		
		return data
	end
end