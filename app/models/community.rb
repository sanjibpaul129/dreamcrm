class Community < ApplicationRecord
	def self.community_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(community_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(community_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
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
		all_communities=[]
		community_data={}
		Community.where(organisation_id: current_personnel.organisation_id).each do |community|
			all_leads.each do |lead|
				if lead.community_id == community.id
					if community_data[community.description]==nil
						community_data[community.description]=1
					else
						community_data[community.description]=community_data[community.description]+1
					end
					if lead.osv==nil && lead.status==false
						if community_data["site visit"]==nil
							community_data["site visit"]=1
						else
							community_data["site visit"] = community_data["site visit"].to_i+1
						end
						community_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						community_data["site visit"]=''
						if community_data["booked"]==nil
							community_data["booked"]=1
						else
							community_data["booked"]=community_data["booked"].to_i+1
						end
					else
						community_data["site visit"]=''
						community_data["booked"]=''
					end
				end	
			end
			all_communities += [community_data]
			community_data={}
		end
		data=[all_communities, unselected_leads_count, unselected_site_visit, unselected_booked]
		
		return data
	end
end
