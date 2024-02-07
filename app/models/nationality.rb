class Nationality < ApplicationRecord
	def self.nationality_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(nationality_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(nationality_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads_count=unselected_leads.count
		unselected_site_visit=0
		unselected_booked=0
		unselected_leads.each do |lead|
			if lead.osv==nil && lead.status==false
				unselected_site_visit+=1
			elsif lead.status==true && lead.lost_reason_id==nil
				unselected_booked+=1
			end	
		end
		all_nationalities=[]
		nationality_data={}
		Nationality.where(organisation_id: current_personnel.organisation_id).each do |nationality|
			all_leads.each do |lead|
				if lead.nationality_id == nationality.id
					if nationality_data[nationality.description]==nil
						nationality_data[nationality.description]=1
					else
						nationality_data[nationality.description]=nationality_data[nationality.description]+1
					end
					if lead.osv==nil && lead.status==false
						if nationality_data["site visit"]==nil
							nationality_data["site visit"]=1
						else
							nationality_data["site visit"] = nationality_data["site visit"].to_i+1
						end
						nationality_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						nationality_data["site visit"]=''
						if nationality_data["booked"]==nil
							nationality_data["booked"]=1
						else
							nationality_data["booked"]=nationality_data["booked"].to_i+1
						end
					else
						nationality_data["site visit"]=''
						nationality_data["booked"]=''
					end
				end	
			end
			all_nationalities += [nationality_data]
			nationality_data={}
		end
		data=[all_nationalities, unselected_leads_count, unselected_site_visit, unselected_booked]
		
		return data
	end
end
