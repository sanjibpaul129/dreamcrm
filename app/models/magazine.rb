class Magazine < ApplicationRecord
	def self.magazine_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(magazine_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(magazine_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
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
		all_magazines=[]
		magazine_data={}
		Magazine.where(organisation_id: current_personnel.organisation_id).each do |magazine|
			all_leads.each do |lead|
				if lead.magazine_id == magazine.id
					if magazine_data[magazine.description]==nil
						magazine_data[magazine.description]=1
					else
						magazine_data[magazine.description]=magazine_data[magazine.description]+1
					end
					if lead.osv==nil && lead.status==false
						if magazine_data["site visit"]==nil
							magazine_data["site visit"]=1
						else
							magazine_data["site visit"] = magazine_data["site visit"].to_i+1
						end
						magazine_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						magazine_data["site visit"]=''
						if magazine_data["booked"]==nil
							magazine_data["booked"]=1
						else
							magazine_data["booked"]=magazine_data["booked"].to_i+1
						end
					else
						magazine_data["site visit"]=''
						magazine_data["booked"]=''
					end
				end	
			end
			all_magazines += [magazine_data]
			magazine_data={}
		end
		data=[all_magazines, unselected_leads_count, unselected_site_visit, unselected_booked]
		
		return data
	end
end
