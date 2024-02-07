class Channel < ApplicationRecord
	def self.channel_wise_lead(data)
		business_unit_id = data[0]
		from = data[1]
		to = data[2]
		current_personnel = data[3]
		all_leads = Lead.where.not(channel_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
		unselected_leads = Lead.where(channel_id: nil).where(business_unit_id: business_unit_id.to_i).where('generated_on >= ? and generated_on <= ?', from.to_datetime.beginning_of_day, to.to_datetime.end_of_day)
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
		all_channels=[]
		channel_data={}
		Channel.where(organisation_id: current_personnel.organisation_id).each do |channel|
			all_leads.each do |lead|
				if lead.channel_id == channel.id
					if channel_data[channel.description]==nil
						channel_data[channel.description]=1
					else
						channel_data[channel.description]=channel_data[channel.description]+1
					end
					if lead.osv==nil && lead.status==false
						if channel_data["site visit"]==nil
							channel_data["site visit"]=1
						else
							channel_data["site visit"] = channel_data["site visit"].to_i+1
						end
						channel_data["booked"]=''
					elsif lead.status==true && lead.lost_reason_id==nil
						channel_data["site visit"]=''
						if channel_data["booked"]==nil
							channel_data["booked"]=1
						else
							channel_data["booked"]=channel_data["booked"].to_i+1
						end
					else
						channel_data["site visit"]=''
						channel_data["booked"]=''
					end
				end	
			end
			all_channels += [channel_data]
			channel_data={}
		end
		data=[all_channels, unselected_leads_count, unselected_site_visit, unselected_booked]
		
		return data
	end
end
