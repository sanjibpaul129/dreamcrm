class Newspaper < ApplicationRecord
	def self.newspaper_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(newspaper_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(newspaper_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
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
		all_newspapers=[]
		newspaper_data={}
		Newspaper.where(organisation_id: current_personnel.organisation_id).each do |newspaper|
			all_leads.each do |lead|
				if lead.newspaper_id == newspaper.id
					if newspaper_data[newspaper.description]==nil
						newspaper_data[newspaper.description]=1
					else
						newspaper_data[newspaper.description]=newspaper_data[newspaper.description]+1
					end
					if lead.osv==nil && lead.status==false
						if newspaper_data["site visit"]==nil
							newspaper_data["site visit"]=1
						else
							newspaper_data["site visit"] = newspaper_data["site visit"].to_i+1
						end
						newspaper_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						newspaper_data["site visit"]=''
						if newspaper_data["booked"]==nil
							newspaper_data["booked"]=1
						else
							newspaper_data["booked"]=newspaper_data["booked"].to_i+1
						end
					else
						newspaper_data["site visit"]=''
						newspaper_data["booked"]=''
					end
				end	
			end
			all_newspapers += [newspaper_data]
			newspaper_data={}
		end
		data=[all_newspapers, unselected_leads_count, unselected_site_visit, unselected_booked]
		
		return data
	end
end
