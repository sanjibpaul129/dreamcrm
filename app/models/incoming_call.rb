require 'httparty'
class IncomingCall < ApplicationRecord
	include HTTParty
	base_uri 'https://konnectprodstream4.knowlarity.com:8200/update-stream/dff4b494-13d3-4c18-b907-9a830de783ef/konnect?source=router'
	def initialize
		@data = ''
	end
	def start_streaming
		counter = 0
		loop_end = 0
		begin
			self.class.get('/stream', stream_body: true) do |chunk|
				p chunk
				p "==========chunk==========="
				counter += 1
				bracket = chunk.index("{")
				comma = chunk.index(",")
				if bracket == nil
				else
					customer_number = ''
					agent_number = ''
					lead = nil
					personnel = nil
					small_data = chunk[bracket..comma]
					colon = small_data.index(":")
					data = small_data[2..11]
					comma = small_data.index(",")
					if data == "event_type"
						call_type = small_data[colon+2..comma-2]
						position_1 = chunk.index("agent_number")
						agent_data = chunk[position_1..position_1+27]
						colon = agent_data.index(":")
						agent_number = agent_data[colon+2..agent_data.length][3..agent_data.length]
						position_2 = chunk.index("customer_number")
						customer_data = chunk[position_2..position_2+30]
						colon = customer_data.index(":")
						customer_number = customer_data[colon+2..customer_data.length][3..customer_data.length]
					end
					personnel = Personnel.where(mobile: agent_number).where('access_right = ? OR access_right is ?', 2, nil)[0]
					if personnel == nil
					else
						lead = Lead.where(mobile: customer_number, personnel_id: personnel.id, lost_reason_id: nil)[0]
					end
					p agent_number
					p "=================="
					p customer_number
					p "=================="
					p personnel
					p "=======personnel======"
					p lead
					p "================Lead==========="
					if counter == 20
						break
					end
					if lead == nil
					else
						if call_type == nil && agent_number == nil
						else
							if call_type == "ORIGINATE"
								Pusher['incoming_call_update'].trigger('push_incoming_call_data', { :url => ["https://www.realtybucket.com/windows/followup_history?id="+lead.id.to_s], :personnel_id => [personnel.id], :name => [lead.name]})
							end
						end
					end
				end
			end
		rescue Net::ReadTimeout => e
			Rails.logger.error "Read timeout error: #{e.message}"
			Rails.logger.info "Reconecting..."
			retry
		rescue StandardError => e
			Rails.logger.error "An error of type #{e.class} occurred, messae is #{e.message}"
		end
		loop_end = 1
		return loop_end
	end
	def data
		@data
	end
end
