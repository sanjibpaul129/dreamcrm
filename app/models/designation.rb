class Designation < ApplicationRecord
	def self.designation_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(designation_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(designation_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
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
		all_designations=[]
		designation_data={}
		Designation.where(organisation_id: current_personnel.organisation_id).each do |designation|
			all_leads.each do |lead|
				if lead.designation_id == designation.id
					if designation_data[designation.description]==nil
						designation_data[designation.description]=1
					else
						designation_data[designation.description]=designation_data[designation.description]+1
					end
					if lead.osv==nil && lead.status==false
						if designation_data["site visit"]==nil
							designation_data["site visit"]=1
						else
							designation_data["site visit"] = designation_data["site visit"].to_i+1
						end
						designation_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						designation_data["site visit"]=''
						if designation_data["booked"]==nil
							designation_data["booked"]=1
						else
							designation_data["booked"]=designation_data["booked"].to_i+1
						end
					else
						designation_data["site visit"]=''
						designation_data["booked"]=''
					end
				end	
			end
			all_designations += [designation_data]
			designation_data={}
		end
		data=[all_designations, unselected_leads_count, unselected_site_visit, unselected_booked]
		
		return data
	end
end
