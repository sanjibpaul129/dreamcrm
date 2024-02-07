class Station < ApplicationRecord
	def self.station_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(station_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(station_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
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
		all_stations=[]
		station_data={}
		Station.where(organisation_id: current_personnel.organisation_id).each do |station|
			all_leads.each do |lead|
				if lead.station_id == station.id
					if station_data[station.description]==nil
						station_data[station.description]=1
					else
						station_data[station.description]=station_data[station.description]+1
					end
					if lead.osv==nil && lead.status==false
						if station_data["site visit"]==nil
							station_data["site visit"]=1
						else
							station_data["site visit"] = station_data["site visit"].to_i+1
						end
						station_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						station_data["site visit"]=''
						if station_data["booked"]==nil
							station_data["booked"]=1
						else
							station_data["booked"]=station_data["booked"].to_i+1
						end
					else
						station_data["site visit"]=''
						station_data["booked"]=''
					end
				end	
			end
			all_stations += [station_data]
			station_data={}
		end
		data=[all_stations, unselected_leads_count, unselected_site_visit, unselected_booked]
		
		return data
	end
end
