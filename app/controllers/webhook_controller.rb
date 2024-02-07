class WebhookController < ApplicationController

protect_from_forgery :except => [:livserve_data]
skip_before_action :verify_authenticity_token, only: [:livserve_data, :magic_bricks_data, :acres_data, :linkedin_data, :facebook_data, :adwords_data, :olx_data, :calls, :highrise_alcove_data, :website_form_data, :check_lead_existence, :create_whatsapp, :fb_whatsapp_lead_creation, :alcove_chat, :rajat_chat, :mobile_check, :chat_id_check, :kiswok, :kiswok_incoming_message, :rajat_calls, :credai_data, :google_drive_call_record, :mark_lead_hot, :qualify_lead, :isv_lead, :ifttt_call_capture, :jsb_calls, :highrise_alcove_status_update, :highrise_alcove_transfer_update, :whatsapp_text_message, :whatsapp_media_message, :whatsapp_map_message, :webhook_chat, :super_receptionist, :jaingroup_website_form_data, :customer_whatsapp_reply_capture, :upload_transcript]
	
	def upload_transcript
		call_id=params['call_id']
		remarks=params['transcript']
		recording_url="https://sr.knowlarity.com/vr/fetchsound/?callid="+call_id
		p recording_url
		telephony_call=TelephonyCall.find_by_recording_url(recording_url)
		p telephony_call
		follow_up=FollowUp.find_by_telephony_call_id(telephony_call.id)
		follow_up.update(remarks: remarks)
		if remarks.include?(' site ') && remarks.include?(' visit')
			follow_up.update(hot: true)
			lead.update(anticipation: 'Good')
		end
		render text: 'transcript uploaded'
	end

	def customer_whatsapp_reply_capture
		require 'json'
		hubVerifyToken = "rubymaster_token"
		if params[:webhook][:entry][0][:changes][0][:value][:statuses] == nil
			other_project_leads = []
			customer_name = params[:webhook][:entry][0][:changes][0][:value][:contacts][0][:profile][:name]
			customer_number = params[:webhook][:entry][0][:changes][0][:value][:contacts][0][:wa_id]
			msg_type = params[:webhook][:entry][0][:changes][0][:value][:messages][0][:type]
			whatsapp_number = params[:webhook][:entry][0][:changes][0][:value][:metadata][:phone_number_id]
			whatsapp_message_id = params[:webhook][:entry][0][:changes][0][:value][:messages][0][:id]
			if msg_type == "button"
				customer_message = params[:webhook][:entry][0][:changes][0][:value][:messages][0][:button][:text]
			elsif msg_type == "interactive"
				customer_message = params[:webhook][:entry][0][:changes][0][:value][:messages][0][:interactive][:button_reply][:title]
			else
				customer_message = params[:webhook][:entry][0][:changes][0][:value][:messages][0][:text][:body]
			end
			if customer_message == "Stop promotions"
				urlstring =  "http://scheduleupdates.herokuapp.com/transaction/holiday_inn_durga_puja_sheet_update?message_status=Stop promotions"+"&customer_number="+customer_number.to_s
				result = HTTParty.get(urlstring)
			elsif whatsapp_number == "117600264705231"
				urlstring =  "http://scheduleupdates.herokuapp.com/transaction/holiday_inn_durga_puja_sheet_update?customer_message="+customer_message.to_s+"&customer_number="+customer_number.to_s
				result = HTTParty.get(urlstring)
			elsif customer_message == "Interested in Dream Gurukul" || customer_message == "I want to know about Dream Gurukul"
				leads = Lead.where(business_unit_id: 70, mobile: customer_number[2..customer_number.length])
				if leads == []
					lead = Lead.new
					lead.name = customer_name
					lead.mobile = customer_number[2..customer_number.length]
					lead.generated_on = DateTime.now
					lead.business_unit_id = 70
					if customer_message == "I want to know about Dream Gurukul"
						lead.source_category_id = 1
					else
						lead.source_category_id = 1060
					end
					lead.transfer_to_back_office
					lead.customer_remarks = "Interested in Dream Gurukul"
					lead.save
				else
					if leads.where(lost_reason_id: nil, booked_on: nil) == []
						lead = Lead.new
						lead.name = customer_name
						lead.mobile = customer_number[2..customer_number.length]
						lead.generated_on = DateTime.now
						lead.reengaged_on = DateTime.now
						lead.business_unit_id = 70
						lead.source_category_id = 1060
						lead.transfer_to_back_office
						lead.customer_remarks = "Interested in Dream Gurukul"
						lead.save	
					end
				end
			else
				broker_contact = nil
				broker_contacts = BrokerContact.where('mobile_one = ? OR mobile_two = ?', customer_number[2..customer_number.length], customer_number[2..customer_number.length])
				if broker_contacts == []
					leads = Lead.where(business_unit_id: 70, mobile: customer_number[2..customer_number.length])
					other_project_leads = Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}, mobile: customer_number[2..customer_number.length], lost_reason_id: nil).where.not(business_unit_id: 70)
					p customer_number
					p "==================customer number================"
					if leads == []
						bot_communication = BotCommunication.new
						bot_communication.customer_number = customer_number
						bot_communication.customer_message = customer_message
						bot_communication.bot_message = ""
						bot_communication.customer_message_id = whatsapp_message_id
						bot_communication.save
					else
						if leads.count == 1
							whatsapp_followup = WhatsappFollowup.new
							whatsapp_followup.lead_id = leads[0].id
							whatsapp_followup.remarks = customer_message
							whatsapp_followup.message_id = whatsapp_message_id
							whatsapp_followup.save
							data = [customer_name, customer_number, customer_message, whatsapp_number, leads[0]]
							UserMailer.lead_whatsapp(data).deliver
						else
							live_lead = leads.where(lost_reason_id: nil, booked_on: nil)[0]
							if live_lead == nil
							else
								whatsapp_followup = WhatsappFollowup.new
								whatsapp_followup.lead_id = live_lead.id
								whatsapp_followup.remarks = customer_message
								whatsapp_followup.message_id = whatsapp_message_id
								whatsapp_followup.save
								data = [customer_name, customer_number, customer_message, whatsapp_number, live_lead]
								UserMailer.lead_whatsapp(data).deliver
							end
						end
					end
					if other_project_leads == []
						file_path = 'content.json'
						content = JSON.parse(File.read(file_path))
						persona = content['persona']
						goal = content['goal']
						project_info = content['project info']
						instructions = content['instructions']
						restrictions = content['restrictions']
						jain_group_info = content['Jain Group Info']
						combined_info = "persona: "+content['persona'].join(' ')+" "+"goal: "+content['goal'].join(' ')+" "+"project info: "+content['project info'].values.join(' ')+" "+"Jain Group Info: "+content['Jain Group Info'].values.join(' ')
						combined_instructions = "instructions: "+content['instructions'].join(' ')+" "+"restrictions: "+content['restrictions'].join(' ')
						enquiry = customer_message
						previous_communications = WhatsappFollowup.includes(:lead).where(:leads => {mobile: customer_number[2..customer_number.length], business_unit_id: 70}).sort_by{|x| x.created_at}
						if previous_communications == [] || previous_communications.count == 1
							# gpt call
							urlstring = "https://api.openai.com/v1/chat/completions"
							model = 'gpt-3.5-turbo-1106'
							messages = [{"role": "system", "content": combined_info}, {"role": "assistant", "content": ""}, {"role": "user", "content": combined_instructions}, {"role": "user", "content": enquiry}]
							result = HTTParty.post(urlstring, body: {model: model,messages: messages}.to_json, headers: {'Content-Type' => 'application/json','Authorization' => "Bearer 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"})
							bot_reply = result.parsed_response['choices'][0]['message']['content']
							p bot_reply
							p "==================================bot_reply======================================"
							# whatsapp msg send to customer
							urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
		                    result = HTTParty.post(urlstring,
		                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => bot_reply}}.to_json,
		                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
		                    p result
			                p "=============result============="
			            	if leads == []
								bot_communication = BotCommunication.new
								bot_communication.customer_number = customer_number
								bot_communication.customer_message = customer_message
								bot_communication.bot_message = bot_reply
								bot_communication.customer_message_id = whatsapp_message_id
								bot_communication.save
							else
								if leads.count == 1
									whatsapp_followup = WhatsappFollowup.new
									whatsapp_followup.lead_id = leads[0].id
									whatsapp_followup.bot_message = bot_reply
									message_data = result.parsed_response
								  	message_id = message_data["messages"]
								  	message_id = message_id[0]["id"]
									whatsapp_followup.message_id = message_id
									whatsapp_followup.save
								else
									live_lead = leads.where(lost_reason_id: nil, booked_on: nil)[0]
									if live_lead == nil
									else
										whatsapp_followup = WhatsappFollowup.new
										whatsapp_followup.lead_id = live_lead.id
										whatsapp_followup.bot_message = bot_reply
										message_data = result.parsed_response
									  	message_id = message_data["messages"]
									  	message_id = message_id[0]["id"]
										whatsapp_followup.message_id = message_id
										whatsapp_followup.save
									end
								end
							end
						else
							# send_message = true
							# previous_communications.each do |previous_communication|
							# 	if previous_communication.remarks == customer_message && previous_communication.message_id == whatsapp_message_id
							# 		send_message = false
							# 	else
							# 		send_message = true
							# 	end
							# end
							# if send_message == true
								urlstring = "https://api.openai.com/v1/chat/completions"
								model = 'gpt-3.5-turbo-1106'
								messages = [{"role": "system", "content": combined_info}, {"role": "assistant", "content": ""}, {"role": "user", "content": combined_instructions}]
								previous_communications.each do |previous_communication|
									if previous_communication.remarks == nil && previous_communication.bot_message != nil
										p "bot message"
										messages += [{"role": "assistant", "content": previous_communication.bot_message}]
									elsif previous_communication.remarks != nil && previous_communication.bot_message == nil
										p "customer message"
										messages += [{"role": "user", "content": previous_communication.remarks}]
									end
								end
								p "========================================================================================"
								p messages
								p "========================================================================================"
								result = HTTParty.post(urlstring, body: {model: model,messages: messages}.to_json, headers: {'Content-Type' => 'application/json','Authorization' => "Bearer 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"})
								p result
								p "==================result===================="
								bot_reply = result.parsed_response['choices'][0]['message']['content']
								p bot_reply
								p "==================================bot_reply======================================"
								urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                    result = HTTParty.post(urlstring,
			                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => bot_reply}}.to_json,
			                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                    p result
				                p "=============result============="
								if leads == []
									bot_communication = BotCommunication.new
									bot_communication.customer_number = customer_number
									bot_communication.customer_message = customer_message
									bot_communication.bot_message = bot_reply
									bot_communication.customer_message_id = whatsapp_message_id
									bot_communication.save
								else
									if leads.count == 1
										whatsapp_followup = WhatsappFollowup.new
										whatsapp_followup.lead_id = leads[0].id
										whatsapp_followup.bot_message = bot_reply
										message_data = result.parsed_response
									  	message_id = message_data["messages"]
									  	message_id = message_id[0]["id"]
										whatsapp_followup.message_id = message_id
										whatsapp_followup.save
									else
										live_lead = leads.where(lost_reason_id: nil, booked_on: nil)[0]
										if live_lead == nil
										else
											whatsapp_followup = WhatsappFollowup.new
											whatsapp_followup.lead_id = live_lead.id
											whatsapp_followup.bot_message = bot_reply
											message_data = result.parsed_response
										  	message_id = message_data["messages"]
										  	message_id = message_id[0]["id"]
											whatsapp_followup.message_id = message_id
											whatsapp_followup.save
										end
									end
								end
							# end
						end
					else
						if leads == []
						else
							file_path = 'content.json'
							content = JSON.parse(File.read(file_path))
							persona = content['persona']
							goal = content['goal']
							project_info = content['project info']
							instructions = content['instructions']
							restrictions = content['restrictions']
							jain_group_info = content['Jain Group Info']
							combined_info = "persona: "+content['persona'].join(' ')+" "+"goal: "+content['goal'].join(' ')+" "+"project info: "+content['project info'].values.join(' ')+" "+"Jain Group Info: "+content['Jain Group Info'].values.join(' ')
							combined_instructions = "instructions: "+content['instructions'].join(' ')+" "+"restrictions: "+content['restrictions'].join(' ')
							enquiry = customer_message
							previous_communications = WhatsappFollowup.includes(:lead).where(:leads => {mobile: customer_number[2..customer_number.length], business_unit_id: 70}).sort_by{|x| x.created_at}
							if previous_communications == [] || previous_communications.count == 1
								# gpt call
								urlstring = "https://api.openai.com/v1/chat/completions"
								model = 'gpt-3.5-turbo-1106'
								messages = [{"role": "system", "content": combined_info}, {"role": "assistant", "content": ""}, {"role": "user", "content": combined_instructions}, {"role": "user", "content": enquiry}]
								result = HTTParty.post(urlstring, body: {model: model,messages: messages}.to_json, headers: {'Content-Type' => 'application/json','Authorization' => "Bearer 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"})
								bot_reply = result.parsed_response['choices'][0]['message']['content']
								p bot_reply
								p "==================================bot_reply======================================"
								# whatsapp msg send to customer
								urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
			                    result = HTTParty.post(urlstring,
			                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => bot_reply}}.to_json,
			                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
			                    p result
				                p "=============result============="
				            	if leads == []
									bot_communication = BotCommunication.new
									bot_communication.customer_number = customer_number
									bot_communication.customer_message = customer_message
									bot_communication.bot_message = bot_reply
									bot_communication.customer_message_id = whatsapp_message_id
									bot_communication.save
								else
									if leads.count == 1
										whatsapp_followup = WhatsappFollowup.new
										whatsapp_followup.lead_id = leads[0].id
										whatsapp_followup.bot_message = bot_reply
										message_data = result.parsed_response
									  	message_id = message_data["messages"]
									  	message_id = message_id[0]["id"]
										whatsapp_followup.message_id = message_id
										whatsapp_followup.save
									else
										live_lead = leads.where(lost_reason_id: nil, booked_on: nil)[0]
										if live_lead == nil
										else
											whatsapp_followup = WhatsappFollowup.new
											whatsapp_followup.lead_id = live_lead.id
											whatsapp_followup.bot_message = bot_reply
											message_data = result.parsed_response
										  	message_id = message_data["messages"]
										  	message_id = message_id[0]["id"]
											whatsapp_followup.message_id = message_id
											whatsapp_followup.save
										end
									end
								end
							else
								# send_message = true
								# previous_communications.each do |previous_communication|
								# 	if previous_communication.remarks == customer_message && previous_communication.message_id == whatsapp_message_id
								# 		send_message = false
								# 	else
								# 		send_message = true
								# 	end
								# end
								# if send_message == true
									urlstring = "https://api.openai.com/v1/chat/completions"
									model = 'gpt-3.5-turbo-1106'
									messages = [{"role": "system", "content": combined_info}, {"role": "assistant", "content": ""}, {"role": "user", "content": combined_instructions}]
									previous_communications.each do |previous_communication|
										if previous_communication.remarks == nil && previous_communication.bot_message != nil
											messages += [{"role": "assistant", "content": previous_communication.bot_message}]
										elsif previous_communication.remarks != nil && previous_communication.bot_message = nil
											messages += [{"role": "user", "content": previous_communication.remarks}]
										end
									end
									messages += [{"role": "user", "content": enquiry}]
									p "========================================================================================"
									p messages
									p "========================================================================================"
									result = HTTParty.post(urlstring, body: {model: model,messages: messages}.to_json, headers: {'Content-Type' => 'application/json','Authorization' => "Bearer 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"})
									p result
									p "==================result===================="
									bot_reply = result.parsed_response['choices'][0]['message']['content']
									p bot_reply
									p "==================================bot_reply======================================"
									urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
				                    result = HTTParty.post(urlstring,
				                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => bot_reply}}.to_json,
				                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
				                    p result
					                p "=============result============="
									if leads == []
										bot_communication = BotCommunication.new
										bot_communication.customer_number = customer_number
										bot_communication.customer_message = customer_message
										bot_communication.bot_message = bot_reply
										bot_communication.customer_message_id = whatsapp_message_id
										bot_communication.save
									else
										if leads.count == 1
											whatsapp_followup = WhatsappFollowup.new
											whatsapp_followup.lead_id = leads[0].id
											whatsapp_followup.bot_message = bot_reply
											message_data = result.parsed_response
										  	message_id = message_data["messages"]
										  	message_id = message_id[0]["id"]
											whatsapp_followup.message_id = message_id
											whatsapp_followup.save
										else
											live_lead = leads.where(lost_reason_id: nil, booked_on: nil)[0]
											if live_lead == nil
											else
												whatsapp_followup = WhatsappFollowup.new
												whatsapp_followup.lead_id = live_lead.id
												whatsapp_followup.bot_message = bot_reply
												message_data = result.parsed_response
											  	message_id = message_data["messages"]
											  	message_id = message_id[0]["id"]
												whatsapp_followup.message_id = message_id
												whatsapp_followup.save
											end
										end
									end
								# end
							end
						end
					end
				else
					if broker_contacts.count == 1
						broker_contact  = broker_contacts[0]
					else
					end
				end

				if broker_contact == nil
				else
					whatsapp_followup = WhatsappFollowup.new
					whatsapp_followup.broker_contact_id = broker_contact.id
					whatsapp_followup.remarks = "Broker Reply: "+customer_message.to_s
					whatsapp_followup.save
					if customer_message == "Accept Invitation"
						broker_contact.update(accept_invitation: true, invitation_reply: true)
						# location
						urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
						if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
            				if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
            				else
            					location_message = "Thank you for accepting! Looking forward to your presence. Hope to see you soon at the event."+"\n"+"\n"+"Please click on the link given below to see the location"+"\n"+"\n"+"*Link:* https://maps.app.goo.gl/SZxbcgXEdHow5UTH9"
								result = HTTParty.post(urlstring,
								:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "text", "text": {"preview_url": false, "body" => location_message}}.to_json,
								:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
								whatsapp_followup = WhatsappFollowup.new
								whatsapp_followup.broker_contact_id = broker_contact.id
								whatsapp_followup.bot_message = "Location Link Sent"
								message_data = result.parsed_response
							  	message_id = message_data["messages"]
							  	message_id = message_id[0]["id"]
								whatsapp_followup.message_id = message_id
								whatsapp_followup.save

								link_text = ""
								if broker_contact.email == nil || broker_contact.email == ""
				                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s
				                else
				                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s+"&email="+broker_contact.try(:email).to_s
				                end
				        		brochure_message = "Please click on the link given below to see the brochure"+"\n"+"\n"+"*Link:* "+link_text.to_s
								result = HTTParty.post(urlstring,
								:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "text", "text": {"preview_url": false, "body" => brochure_message}}.to_json,
								:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})        
								whatsapp_followup = WhatsappFollowup.new
								whatsapp_followup.broker_contact_id = broker_contact.id
								whatsapp_followup.bot_message = "Brochure Link Sent"
								message_data = result.parsed_response
							  	message_id = message_data["messages"]
							  	message_id = message_id[0]["id"]
								whatsapp_followup.message_id = message_id
								whatsapp_followup.save

								agreement_message = "As a valued participent in our special partner's meet, We're pleased to offer an exclusive Channel Partner's Accelerator Scheme. Earn up to 4% commission for 60 days, starting from 1st December 2023, or upon contract signing whichever is later."+"\n"+"Please click on the link given below to sign the *Channel Partner Contract*"+"\n"+"\n"+"*Link:* https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker_id.to_s
								result = HTTParty.post(urlstring,
								:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "text", "text": {"preview_url": false, "body" => agreement_message}}.to_json,
								:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
								whatsapp_followup = WhatsappFollowup.new
								whatsapp_followup.broker_contact_id = broker_contact.id
								whatsapp_followup.bot_message = "Agreement Link Sent"
								message_data = result.parsed_response
							  	message_id = message_data["messages"]
							  	message_id = message_id[0]["id"]
								whatsapp_followup.message_id = message_id
								whatsapp_followup.save
            				end
            			else
            				location_message = "Thank you for accepting! Looking forward to your presence. Hope to see you soon at the event."+"\n"+"\n"+"Please click on the link given below to see the location"+"\n"+"\n"+"*Link:* https://maps.app.goo.gl/SZxbcgXEdHow5UTH9"
							result = HTTParty.post(urlstring,
							:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "text", "text": {"preview_url": false, "body" => location_message}}.to_json,
							:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
							whatsapp_followup = WhatsappFollowup.new
							whatsapp_followup.broker_contact_id = broker_contact.id
							whatsapp_followup.bot_message = "Location Link Sent"
							message_data = result.parsed_response
						  	message_id = message_data["messages"]
						  	message_id = message_id[0]["id"]
							whatsapp_followup.message_id = message_id
							whatsapp_followup.save

							link_text = ""
							if broker_contact.email == nil || broker_contact.email == ""
			                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s
			                else
			                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s+"&email="+broker_contact.try(:email).to_s
			                end
			        		brochure_message = "Please click on the link given below to see the brochure"+"\n"+"\n"+"*Link:* "+link_text.to_s
							result = HTTParty.post(urlstring,
							:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "text", "text": {"preview_url": false, "body" => brochure_message}}.to_json,
							:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})        
							whatsapp_followup = WhatsappFollowup.new
							whatsapp_followup.broker_contact_id = broker_contact.id
							whatsapp_followup.bot_message = "Brochure Link Sent"
							message_data = result.parsed_response
						  	message_id = message_data["messages"]
						  	message_id = message_id[0]["id"]
							whatsapp_followup.message_id = message_id
							whatsapp_followup.save

							agreement_message = "As a valued participent in our special partner's meet, We're pleased to offer an exclusive Channel Partner's Accelerator Scheme. Earn up to 4% commission for 60 days, starting from 1st December 2023, or upon contract signing whichever is later."+"\n"+"Please click on the link given below to sign the *Channel Partner Contract*"+"\n"+"\n"+"*Link:* https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker_id.to_s
							result = HTTParty.post(urlstring,
							:body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "text", "text": {"preview_url": false, "body" => agreement_message}}.to_json,
							:headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
							whatsapp_followup = WhatsappFollowup.new
							whatsapp_followup.broker_contact_id = broker_contact.id
							whatsapp_followup.bot_message = "Agreement Link Sent"
							message_data = result.parsed_response
						  	message_id = message_data["messages"]
						  	message_id = message_id[0]["id"]
							whatsapp_followup.message_id = message_id
							whatsapp_followup.save
            			end
					elsif customer_message == "Not Interested"
						broker_contact.update(accept_invitation: false, inactive: true) 
					end
					data = [customer_name, customer_number, customer_message, whatsapp_number, broker_contact]
					UserMailer.customer_whatsapp(data).deliver
				end
			end
		else
			number_id = params[:webhook][:entry][0][:changes][0][:value][:metadata][:phone_number_id]
			p number_id
			p "=============number id==========="
			if number_id == "117600264705231"
				message_status = params[:webhook][:entry][0][:changes][0][:value][:statuses][0][:status]
				customer_number = params[:webhook][:entry][0][:changes][0][:value][:statuses][0][:recipient_id]
				if message_status == "sent"
				else
					urlstring =  "http://scheduleupdates.herokuapp.com/transaction/holiday_inn_durga_puja_sheet_update?message_status="+message_status.to_s+"&customer_number="+customer_number.to_s
					result = HTTParty.get(urlstring)
				end
			else
				message_status = params[:webhook][:entry][0][:changes][0][:value][:statuses][0][:status]
				customer_number = params[:webhook][:entry][0][:changes][0][:value][:statuses][0][:recipient_id]
				message_id = params[:webhook][:entry][0][:changes][0][:value][:statuses][0][:id]
				broker_contact = nil
				broker_contacts = BrokerContact.where('mobile_one = ? OR mobile_two = ?', customer_number[2..customer_number.length], customer_number[2..customer_number.length])
				if broker_contacts == []
				else
					if broker_contacts.count == 1
						broker_contact  = broker_contacts[0]
					else
					end
				end
				if message_status == "delivered"
					if broker_contact == nil
						leads = Lead.where(business_unit_id: 70, mobile: customer_number[2..customer_number.length])
						if leads == []
						else
							if leads.count == 1
								whatsapp_followup = WhatsappFollowup.where(lead_id: leads[0].id, message_id: message_id)[0]
								if whatsapp_followup == nil
								else
									whatsapp_followup.update(delivered_on: DateTime.now)
								end
							else
								live_lead = leads.where(lost_reason_id: nil, booked_on: nil)[0]
								whatsapp_followup = WhatsappFollowup.where(lead_id: live_lead.id, message_id: message_id)[0]
								if whatsapp_followup == nil
								else
									whatsapp_followup.update(delivered_on: DateTime.now)
								end
							end
						end
					else
						whatsapp_followup = WhatsappFollowup.where(broker_contact_id: broker_contact.id, message_id: message_id)[0]
						if whatsapp_followup == nil
						else
							whatsapp_followup.update(delivered_on: DateTime.now)
						end
					end				
				elsif message_status == "read"
					if broker_contact == nil
						leads = Lead.where(business_unit_id: 70, mobile: customer_number[2..customer_number.length])
						if leads == []
						else
							if leads.count == 1
								whatsapp_followup = WhatsappFollowup.where(lead_id: leads[0].id, message_id: message_id)[0]
								if whatsapp_followup == nil
								else
									whatsapp_followup.update(read_on: DateTime.now)
								end
							else
								live_lead = leads.where(lost_reason_id: nil, booked_on: nil)[0]
								whatsapp_followup = WhatsappFollowup.where(lead_id: live_lead.id, message_id: message_id)[0]
								if whatsapp_followup == nil
								else
									whatsapp_followup.update(read_on: DateTime.now)
								end
							end
						end
					else
						whatsapp_followup = WhatsappFollowup.where(broker_contact_id: broker_contact.id, message_id: message_id)[0]
						if whatsapp_followup == nil
						else
							whatsapp_followup.update(read_on: DateTime.now)
							if whatsapp_followup.bot_message == "Invitation message sent"
								whatsapp_followup.broker_contact.update(invitation_read: true)
							end
						end
					end				
				end
			end
		end
		if params[:"hub.verify_token"] == hubVerifyToken
			render :text => params[:"hub.challenge"]
		else
			render :nothing => true
		end
	end

	def site_visit_feedback
		p params
		p "========================================"
	end

	def google_drive_call_record
		mobile=params['mobile']
		datetime=params['datetime']
		email=params['email']
		recording_link=params['recording_link']

		personnel=Personnel.find_by_email(email)
		if Personnel.find_by(mobile: mobile, organisation_id: personnel.organisation_id)==nil
			leads=Lead.where(mobile: mobile, personnel_id: personnel.id).where('status = ? OR status is ?', false, nil)
			if leads==[]
			leads=Lead.where(mobile: mobile, personnel_id: personnel.id)
				if leads==[]
					leads=Lead.includes(:personnel).where(:leads => {mobile: mobile}, :personnels => {organisation_id: personnel.organisation_id})
					if leads==[]
					else
						lead=leads.sort_by{|x| x.created_at}.last
						call_record=CallRecord.new
						call_record.lead_id=lead.id
						call_record.personnel_id=personnel.id
						call_record.url=recording_link
						call_record.occurred_at=datetime.to_datetime
						call_record.save
					end
				else
					lead=leads.sort_by{|x| x.created_at}.last
					call_record=CallRecord.new
					call_record.lead_id=lead.id
					call_record.personnel_id=personnel.id
					call_record.url=recording_link
					call_record.occurred_at=datetime.to_datetime
					call_record.save
				end
			else
				lead=leads.sort_by{|x| x.created_at}.last
				call_record=CallRecord.new
				call_record.lead_id=lead.id
				call_record.personnel_id=personnel.id
				call_record.url=recording_link
				call_record.occurred_at=datetime.to_datetime
				call_record.save
			end
		end
		render :text => "Success-"+mobile+','+datetime
	end

	def highrise_alcove_data
		apikey=params[:apikey]
		organisation=Organisation.find_by_api_key(apikey)
		customer_name=params[:name].to_s
		mobile=params[:mobile].to_s
		email=params[:email].to_s
		project_name=params[:project]
		source_name=params[:source].to_s
		generated_on=params[:generated_on]
		comments=params[:reference].to_s
		budget=params[:budget]
		location=params[:location].to_s
		bhk=params[:bhk].to_s
		executive_name=[:executive].to_s
		enquiry_id=params[:reference].to_s


		if project_name != nil
			if project_name.downcase.include? 'sangam'
			business_unit=BusinessUnit.find_by_name('New Kolkata Sangam')
			elsif project_name.downcase.include? 'prayag'
			business_unit=BusinessUnit.find_by_name('New Kolkata Prayag')	
			end
		end

		# UserMailer.api_testing(['highrise_alcove_data', 'temp', params]).deliver

		if enquiry_id != "219150"

			if business_unit==nil
				UserMailer.api_testing(['highrise_alcove_data', 'project not found', params]).deliver
			elsif mobile==""
				UserMailer.api_testing(['highrise_alcove_data', 'mobile blank', params]).deliver
			elsif mobile.length < 10
				UserMailer.api_testing(['highrise_alcove_data', 'mobile invalid', params]).deliver
			else
				new_lead=Lead.new
				new_lead.business_unit_id=business_unit.id
				new_lead.generated_on=Time.now
				new_lead.name=customer_name
				length_of_number=mobile.length
				new_lead.mobile=mobile[(length_of_number-10)..(length_of_number-1)]
				old_source=SourceCategory.find_by(organisation_id: organisation.id, description: 'NA')
				if old_source==nil
					new_source=SourceCategory.new
					new_source.organisation_id=organisation.id
					new_source.description=source_name
					new_source.heirarchy=source_name
					new_source.save
					new_lead.source_category_id=new_source.id
				else
					new_lead.source_category_id=old_source.id
				end

				new_lead.personnel_id=Personnel.find_by(name: 'Tausif', organisation_id: organisation.id).id	
				new_lead.customer_remarks='Location: '+location.to_s+', Remarks: '+comments	
				new_lead.budget_from=budget.to_i
				new_lead.budget_to=budget.to_i
				new_lead.flat_type=bhk.to_s.to_i

				    if new_lead.business_unit.name=='New Kolkata Sangam'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
				  		@result = HTTParty.post(urlstring,
						   :body => { :to_number => '+91'+new_lead.mobile,
	                		 :message => "https://drive.google.com/uc?id=1ZpLdLUiIWZACu6gnoMr98IOkJ2AjINHJ&export=download",	
	                          :text => "",
	                          :type => "media"
	                          }.to_json,
	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
					
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
				  		@result = HTTParty.post(urlstring,
						   :body => { :to_number => '+91'+new_lead.mobile,
	                		 :message => "https://dsm01pap001files.storage.live.com/y4m_lCh7P2tO7vgyuBKA0aImk6fpNU1eoNnrXsZ88iXEe68wlbpyyDAagpkHuebCeuAGYwwb6bGQZiWDzfHwhkIComeHhmMJu2KJK6Fd91Nfko7cG8jDJo-qXmkTJzhofVNqUdVp38wr2yATcFnKSTx8LkIjOwqNkTXv5s7bp3rLs89JbbrblfWt-y_hE1NJXHJ?width=1080&height=985&cropmode=none",	
	                          :text => "Hi "+customer_name+",\n\nThank you for your interest in "+business_unit.name+". Please expect a call-back from our representative at the earliest possible."+".\n\nMeanwhile, we can help you with the following 👇\n\n1. Brochure\n2. Plans\n3. Location\n4. Video/Photo Gallery\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n8. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
	                          :type => "media"
	                          }.to_json,
	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

				    else
				    urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
				  		@result = HTTParty.post(urlstring,
						   :body => { :to_number => '+91'+new_lead.mobile,
	                		 :message => "https://drive.google.com/uc?id=1ZpLdLUiIWZACu6gnoMr98IOkJ2AjINHJ&export=download",	
	                          :text => "",
	                          :type => "media"
	                          }.to_json,
	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
				    
				    urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
				  		@result = HTTParty.post(urlstring,
						   :body => { :to_number => '+91'+new_lead.mobile,
	                		 :message => "https://dsm01pap001files.storage.live.com/y4m0UoLFbjcVqhkhZffumkk4g1KJ4pVTSU6jV4BS8X2UnIPVQyZEqKuuKzkrs5k4yKCVb3Cyjai80CFz4tRJ-LFQ4xpCYfqf2Z7JKMlaSiIk7hIMvcBuu6lSwsxY8q7oQrmtY5HV05hYQLFOg2f-xFrGfhgeWeDTjIuCBNxw9lSn2QON21-oQqm9gqlW5HmN2eu?width=1080&height=1080&cropmode=none",	
	                          :text => "Hi "+customer_name+",\n\nThank you for your interest in "+business_unit.name+". Please expect a call-back from our representative at the earliest possible."+".\n\nMeanwhile, we can help you with the following 👇\n\n1. Brochure\n2. Plans\n3. Location\n4. Video/Photo Gallery\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n8. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
	                          :type => "media"
	                          }.to_json,
	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            
				    
				  	end
				
				    
					if @result["success"]    
					new_lead.save
				    lead_whatsapp=Whatsapp.new
				    lead_whatsapp.lead_id=new_lead.id
				    lead_whatsapp.message='introductory message'
				    lead_whatsapp.save
					# UserMailer.api_testing(['alcove_data', 'success message - ', params]).deliver
					else
					UserMailer.api_testing(['highrise_alcove_data', 'whatsapp error due to ', params]).deliver
					end

			end
		else
			new_lead=true
		end
		
		if new_lead != nil		
		render :text => 'SUCCESS'
		else
		render :text => 'Lead not captured :('	
		end				
	
	end

	def highrise_alcove_status_update
		UserMailer.api_testing_other(['al status update', 'status', 'Alcove Group', params]).deliver
		render text: 'test successful'
	end

	def highrise_alcove_transfer_update
		UserMailer.api_testing_other(['al transfer update', 'status', 'Alcove Group', params]).deliver
		render text: 'test successful'
	end

	def whatsapp_text_message
		UserMailer.api_testing_other(['al text msg', 'status', 'Alcove Group', params]).deliver
		render text: 'test successful'
	end

	def whatsapp_media_message
		UserMailer.api_testing_other(['al transfer update', 'status', 'Alcove Group', params]).deliver
		render text: 'test successful'
	end

	def whatsapp_map_message
		UserMailer.api_testing_other(['al transfer update', 'status', 'Alcove Group', params]).deliver
		render text: 'test successful'
	end

	def magic_bricks_data
		# apikey=kG6vgYgUqEmnHUtHX15pNQ
		apikey=params[:apikey]
		organisation=Organisation.find_by_api_key(apikey)
		customer_name=params[:name]
		if params[:isd]==nil || params[:isd]=='91'
		mobile=params[:mobile]
		else
		mobile=params[:isd]+params[:mobile]	
		end
		email=params[:email]
		project_name=params['ProjectName']
		if project_name==nil
			project_name=params['ProjectTest']
		end
		comments=params[:comments]

		@data = ['magic_bricks', params, organisation.name, customer_name, mobile, email, project_name, comments]
		# UserMailer.api_testing_other(['magic_bricks_testing', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
		

		project=BusinessUnit.find_by_name(project_name)
		if project==nil && organisation.id==1
		project=BusinessUnit.find_by_name('Dream World City')	
		elsif project==nil
		UserMailer.api_testing_other(['magic_bricks_project_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
		else
		# UserMailer.api_testing_other(['magic_bricks_project_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
		auto_lead=Lead.new

		auto_lead.generated_on=Time.now
		auto_lead.name=customer_name
		auto_lead.business_unit_id=project.id
		auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Magicbricks').id
			if auto_lead.source_category_id==nil
				UserMailer.api_testing_other(['magic_bricks_source_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
			else
				auto_lead.email=email
				auto_lead.mobile=mobile
				auto_lead.customer_remarks=comments
				if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil
				auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))
				elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil
				auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))
				elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[]
				auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
				elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
				auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))
				elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
				auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))
				elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
				auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
				else
					if organisation.name=='Jain Group'
						if organisation.holiday==true || auto_lead.business_unit.auto_allocate==true
							auto_lead.transfer_to_back_office
						elsif organisation.auto_allocate==true || auto_lead.business_unit.auto_allocate==true
							auto_lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).sunday?
							auto_lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).saturday?
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
							auto_lead.transfer_to_back_office
							else
							auto_lead.transfer_to_back_office
							end		
						else
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
							auto_lead.transfer_to_back_office
							else
							auto_lead.transfer_to_back_office
							end
						end
					elsif organisation.name=='Oswal Group'
						if project_name=='Orchard 126'
						auto_lead.personnel_id=Personnel.find_by(name: 'Arindam Basu', organisation_id: organisation.id).id
						else
						auto_lead.personnel_id=Personnel.find_by(email: 'customercare@oswalgroup.net', organisation_id: organisation.id).id	
						end
					elsif organisation.name=='Rajat Group'
						if project_name=='Southern Vista'
						auto_lead.transfer_to_back_office
						else
						auto_lead.personnel_id=Personnel.find_by_email('medwina@rajathomes.com').id	
						end	
					end
					auto_lead.save
					UserMailer.new_lead_notification(auto_lead).deliver
					
					executive_number='91'+auto_lead.personnel.mobile
					
					urlstring =  "https://api-ssl.bitly.com/v4/shorten"
					          result = HTTParty.post(urlstring,
					             :body => { :long_url => 'http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s,
					              :domain => "bit.ly"}.to_json,
					                :headers => {'Content-Type' => 'application/json', 'Authorization'=>'Bearer 8b07cc3262b4028c856009329703c30d769071cf' } )    

					short_link='http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.alpha_id                 
					

					if auto_lead.mobile != nil && auto_lead.email != nil
					message="Source: Magic Bricks, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ short_link
					elsif auto_lead.mobile != nil
					message="Source: Magic Bricks, "+ auto_lead.name+", "+auto_lead.mobile+", "+ short_link
					elsif auto_lead.email != nil
					message="Source: Magic Bricks, "+ auto_lead.name+", "+auto_lead.email+", "+ short_link
					end	
					if organisation.whatsapp_instance==nil
					urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+auto_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
					response=HTTParty.get(urlstring)
					else
						if organisation.name=='Rajat Group'
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
					                		 :message => message,	
					                          :type => "text"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
						end
					end
				# UserMailer.api_testing_other(['magic_bricks_saved', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
				end
			end
		end
	render :nothing => true
	end

	def credai_data
		# apikey=kG6vgYgUqEmnHUtHX15pNQ
		apikey=params[:apikey]
		organisation=Organisation.find_by_api_key(apikey)
		customer_name=params[:name]
		mobile=params[:phone]
		email=params[:email]
		project_name=params[:project]
		comments=params[:comments]

		@data = ['credai_listing', params, organisation.name, customer_name, mobile, email, project_name, comments]
		# UserMailer.api_testing_other(['credai testing', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
		

		project=BusinessUnit.find_by_name(project_name)
		if project==nil && organisation.id==1
		project=BusinessUnit.find_by_name('Dream World City')	
		elsif project==nil
		UserMailer.api_testing_other(['credai_project_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
		else
		auto_lead=Lead.new

		auto_lead.generated_on=Time.now
		auto_lead.name=customer_name
		auto_lead.business_unit_id=project.id
		auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Credai Listing').id
			if auto_lead.source_category_id==nil
				UserMailer.api_testing_other(['credai_listing_source_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
			else
				auto_lead.email=email
				auto_lead.mobile=mobile
				auto_lead.customer_remarks=comments	
				if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil && mobile != '' && mobile != nil
				auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))
				elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil && mobile != '' && mobile != nil
				auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))
				elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && mobile != '' && mobile != nil
				auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
				elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
				auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))
				elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
				auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))
				elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
				auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
				else
					if organisation.name=='Jain Group'
						if organisation.holiday==true || auto_lead.business_unit.auto_allocate==true
							auto_lead.transfer_to_back_office
						elsif organisation.auto_allocate==true || auto_lead.business_unit.auto_allocate==true
							auto_lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).sunday?
							auto_lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).saturday?
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
							auto_lead.transfer_to_back_office
							else
							auto_lead.transfer_to_back_office
							end		
						else
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
							auto_lead.transfer_to_back_office
							else
							auto_lead.transfer_to_back_office
							end
						end
					elsif organisation.name=='Oswal Group'
						if project_name=='Orchard 126'
						auto_lead.personnel_id=Personnel.find_by(name: 'Arindam Basu', organisation_id: organisation.id).id
						else
						auto_lead.personnel_id=Personnel.find_by(email: 'customercare@oswalgroup.net', organisation_id: organisation.id).id	
						end
					elsif organisation.name=='Rajat Group'
						if project_name=='Southern Vista'
						auto_lead.transfer_to_back_office
						else
						auto_lead.personnel_id=Personnel.find_by_email('medwina@rajathomes.com').id	
						end	
					end
				auto_lead.save
				UserMailer.new_lead_notification(auto_lead).deliver
				
				executive_number='91'+auto_lead.personnel.mobile

				urlstring =  "https://api-ssl.bitly.com/v4/shorten"
				          result = HTTParty.post(urlstring,
				             :body => { :long_url => 'http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s,
				              :domain => "bit.ly"}.to_json,
				                :headers => {'Content-Type' => 'application/json', 'Authorization'=>'Bearer 8b07cc3262b4028c856009329703c30d769071cf' } )    

				short_link='http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.alpha_id                
				

				if auto_lead.mobile != nil && auto_lead.email != nil
				message="Source: Credai Listing, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ short_link
				elsif auto_lead.mobile != nil
				message="Source: Credai Listing, "+ auto_lead.name+", "+auto_lead.mobile+", "+ short_link
				elsif auto_lead.email != nil
				message="Source: Credai Listing, "+ auto_lead.name+", "+auto_lead.email+", "+ short_link
				end	
				if organisation.whatsapp_instance==nil
				urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+auto_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
				response=HTTParty.get(urlstring)
				else
					if organisation.name=='Rajat Group'
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
					                		 :message => message,	
					                          :type => "text"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
		
						
					end
				end
				# UserMailer.api_testing_other(['magic_bricks_saved', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
				end
			end
		end
	render :nothing => true
	end

	def housing_data
		# apikey=kG6vgYgUqEmnHUtHX15pNQ
		apikey=params[:apikey]
		organisation=Organisation.find_by_api_key(apikey)
		customer_name=params[:name]
		mobile=params[:mobile]
		email=params[:email]
		project_name=params['ProjectName']
		if project_name==nil
			project_name=params['ProjectTest']
		end
		comments=params[:comments]

		@data = ['housing', params, organisation.name, customer_name, mobile, email, project_name, comments]

		project=BusinessUnit.find_by_name(project_name)
		if project==nil
		UserMailer.api_testing_other(['housing_project_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
		else
		
		auto_lead=Lead.new

		auto_lead.generated_on=Time.now
		auto_lead.name=customer_name
		auto_lead.business_unit_id=project.id
		auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Housing').id
			if auto_lead.source_category_id==nil
				UserMailer.api_testing_other(['housing_source_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
			else
				auto_lead.email=email
				auto_lead.mobile=mobile
				auto_lead.customer_remarks=comments	
				if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil
				auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))
				elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil
				auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))
				elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[]
				auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
				elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
				auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))
				elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
				auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))
				elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
				auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
				else
					if organisation.name=='Jain Group'
						if organisation.holiday==true || auto_lead.business_unit.auto_allocate==true
							auto_lead.transfer_to_back_office
						elsif organisation.auto_allocate==true || auto_lead.business_unit.auto_allocate==true
							auto_lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).sunday?
							auto_lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).saturday?
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
							auto_lead.transfer_to_back_office
							else
							auto_lead.transfer_to_back_office
							end		
						else
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
							auto_lead.transfer_to_back_office
							else
							auto_lead.transfer_to_back_office
							end
						end
					elsif organisation.name=='Oswal Group'
						if project_name=='Orchard 126'
						auto_lead.personnel_id=Personnel.find_by(name: 'Arindam Basu', organisation_id: organisation.id).id
						else
						auto_lead.personnel_id=Personnel.find_by(email: 'customercare@oswalgroup.net', organisation_id: organisation.id).id	
						end
					elsif organisation.name=='Rajat Group'
						if project_name=='Southern Vista'
						auto_lead.transfer_to_back_office
						else
						auto_lead.personnel_id=Personnel.find_by_email('medwina@rajathomes.com').id	
						end		
					end
				auto_lead.save
				UserMailer.new_lead_notification(auto_lead).deliver
				
				executive_number='91'+auto_lead.personnel.mobile

				urlstring =  "https://api-ssl.bitly.com/v4/shorten"
				          result = HTTParty.post(urlstring,
				             :body => { :long_url => 'http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s,
				              :domain => "bit.ly"}.to_json,
				                :headers => {'Content-Type' => 'application/json', 'Authorization'=>'Bearer 8b07cc3262b4028c856009329703c30d769071cf' } )    

				short_link='http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.alpha_id                
				
				if auto_lead.mobile != nil && auto_lead.email != nil
				message="Source: Housing, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ short_link
				elsif auto_lead.mobile != nil
				message="Source: Housing, "+ auto_lead.name+", "+auto_lead.mobile+", "+ short_link
				elsif auto_lead.email != nil
				message="Source: Housing, "+ auto_lead.name+", "+auto_lead.email+", "+ short_link
				end	
				if organisation.whatsapp_instance==nil
				urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+auto_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
				response=HTTParty.get(urlstring)
				else

					if organisation.name=='Rajat Group'	
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
				                		 :message => message,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
					end

				# urlstring =  "https://eu71.chat-api.com/instance"+organisation.whatsapp_instance+"/sendMessage?token="+organisation.whatsapp_key
				# 	  		result = HTTParty.get(urlstring,
				# 			   :body => { :phone => "91"+(auto_lead.personnel.mobile),
				# 			              :body => message 
				# 			              }.to_json,
				# 			   :headers => { 'Content-Type' => 'application/json' } )
				end
				# UserMailer.api_testing_other(['housing_saved', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
				end
			end
		end
	render :nothing => true
	end

	def acres_data

		apikey=params[:apikey]
		organisation=Organisation.find_by_api_key(apikey)

		xml=params['Xml']
		
		data=Hash.from_xml(xml)['Xml']['Qry']

		if data.kind_of?(Array)
		else
		data=[data]
		end
		
		@leads_captured=[]
			
		data.each do |lead|

			customer_name=lead['Name']
			if lead['Phone'].split(//).first(2).join=='91'
			mobile=lead['Phone'].split(//).last(10).join
			else
			mobile=lead['Phone'].gsub('-','')	
			end
			email=lead['Email']
			if lead['ProjectName']==''
				if organisation.name=='Jain Group'
				project_name='Dream World City'
				elsif organisation.name=='Oswal Group'
				project_name='Orchard 126'
				elsif organisation.name=='Rajat Group'
				project_name='Southern Vista'	
				end
			else
				if organisation.name=='Rajat Group' || organisation.name=='Jain Group'
				project_name=lead['ProjectName']
				else	
				# project_name=lead['ProjectName'].at(((lead['ProjectName'].index(' '))+1)..lead['ProjectName'].length)	
				end
			end
			comments=lead['QryInfo']
			lead_id=lead['QryId']
			@data = ['99 Acres', lead_id , organisation.name, customer_name, mobile, email, project_name, comments, params]

			project=BusinessUnit.find_by_name(project_name)
			if project==nil
			UserMailer.api_testing_other(['99_acres_project_not_found', lead_id, organisation.name, customer_name, mobile, email, project_name, comments, params]).deliver	
			else
			auto_lead=Lead.new

			auto_lead.generated_on=lead['RcvdOn'].to_datetime
			auto_lead.name=customer_name
			auto_lead.business_unit_id=project.id
			if organisation.name=='Rajat Group'
				if lead['ProdType']=='OA'
				auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Omni').id	
				elsif lead['ProdType']=='MM'
				auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Mailer').id	
				elsif lead['ProdType']=='PL'
				auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Listing').id	
				elsif lead['ProdType']=='CS' || lead['ProdType']=='NP' || lead['ProdType']=='PG' || lead['ProdType']=='FP'
				auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'New Project').id	
				else 	
				auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: '99 Acres').id
				end
			else
			auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: '99 Acres').id
			end
				if auto_lead.source_category_id==nil
					UserMailer.api_testing_other(['99_acres_source_not_found', lead_id, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
				else
					auto_lead.email=email
					auto_lead.mobile=mobile
					auto_lead.customer_remarks=comments	
					if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil
					auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))
					elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil
					auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))
					elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[]
					auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
					auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
					auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))
					elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
					auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
					else
						if organisation.name=='Jain Group'
							if organisation.holiday==true
								auto_lead.transfer_to_back_office
							elsif organisation.auto_allocate==true || auto_lead.business_unit.auto_allocate==true
								auto_lead.transfer_to_back_office
							elsif (Time.now+5.hours+30.minutes).sunday?
								auto_lead.transfer_to_back_office
	 						elsif (Time.now+5.hours+30.minutes).saturday?
								if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
								auto_lead.transfer_to_back_office
								else
								auto_lead.transfer_to_back_office
								end		
							else
								if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
								auto_lead.transfer_to_back_office
								else
								auto_lead.transfer_to_back_office
								end
							end
						elsif organisation.name=='Oswal Group'
							if project_name=='Orchard 126'
							auto_lead.personnel_id=Personnel.find_by(name: 'Arindam Basu', organisation_id: organisation.id).id
							else
							auto_lead.personnel_id=Personnel.find_by(email: 'customercare@oswalgroup.net', organisation_id: organisation.id).id	
							end
						elsif organisation.name=='Rajat Group'
							if project_name=='Southern Vista'
							auto_lead.transfer_to_back_office
							else
							auto_lead.personnel_id=Personnel.find_by_email('medwina@rajathomes.com').id	
							end
						elsif organisation.name=='JSB Infrastructures'
							auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
						end
					auto_lead.save
					UserMailer.new_lead_notification(auto_lead).deliver
					
					executive_number='91'+auto_lead.personnel.mobile

					urlstring =  "https://api-ssl.bitly.com/v4/shorten"
					          result = HTTParty.post(urlstring,
					             :body => { :long_url => 'http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s,
					              :domain => "bit.ly"}.to_json,
					                :headers => {'Content-Type' => 'application/json', 'Authorization'=>'Bearer 8b07cc3262b4028c856009329703c30d769071cf' } )    

					short_link='http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.alpha_id                
					
					if auto_lead.mobile != nil && auto_lead.email != nil
					message="Source: 99Acres, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ short_link
					elsif auto_lead.mobile != nil
					message="Source: 99Acres, "+ auto_lead.name+", "+auto_lead.mobile+", "+ short_link
					elsif auto_lead.email != nil
					message="Source: 99Acres, "+ auto_lead.name+", "+auto_lead.email+", "+ short_link
					end
					if organisation.whatsapp_instance==nil	
					urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+auto_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
					response=HTTParty.get(urlstring)
					else

					if organisation.name=='Rajat Group'
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
				                		 :message => message,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
					end
						
					# urlstring =  "https://eu71.chat-api.com/instance"+organisation.whatsapp_instance+"/sendMessage?token="+organisation.whatsapp_key
					# 	  		result = HTTParty.get(urlstring,
					# 			   :body => { :phone => "91"+(auto_lead.personnel.mobile),
					# 			              :body => message 
					# 			              }.to_json,
					# 			   :headers => { 'Content-Type' => 'application/json' } )
					end
					# UserMailer.api_testing_other(['99_acres_saved '+organisation.name, lead_id, organisation.name, customer_name, mobile, email, project_name, comments, params]).deliver	
					end
				@leads_captured+=[lead_id]	
				end
			end
		end
					
	end

	def linkedin_data
		p params
		# apikey=params[:apikey]
		# organisation=Organisation.find_by_api_key(apikey)
		project=BusinessUnit.find_by_name('Aagaman')
		first_name=params[:first_name]
		last_name=params[:last_name]
		customer_name=first_name+" "+last_name
		email=params[:email]
		mobile=params[:mobile]
		mobile=mobile.gsub(/\s+/, "")
		mobile=mobile.split(//).last(10).join
		remarks=params[:remarks]
		auto_lead=Lead.new
		auto_lead.generated_on=Time.now
		auto_lead.name=customer_name
		auto_lead.mobile=mobile
		auto_lead.email=email
		auto_lead.customer_remarks=remarks
		auto_lead.source_category_id=5939
		auto_lead.business_unit_id=project.id
		auto_lead.transfer_to_back_office
		auto_lead.save
		render :nothing => true	
	end

	def facebook_data
		# apikey=kG6vgYgUqEmnHUtHX15pNQ
			# UserMailer.api_testing_other(['all data to understand split', params]).deliver	
			
			apikey=params[:apikey]
			organisation=Organisation.find_by_api_key(apikey)
			customer_name=params[:name]
			if params[:mobile]==nil
			raw_mobile=params[:raw_mobile]
			UserMailer.api_testing_other(['all data to understand split', params]).deliver	
			else
				if params[:raw_mobile] != nil
				raw_mobile=params[:raw_mobile]	
				mobile_stripped=raw_mobile.gsub(/\s+/, "")
				other_number=mobile_stripped.split(//).last(10).join
				else
				other_number=params[:other_number].to_s
				end
			raw_mobile=params[:mobile]	
			end
			if params[:email]==nil
			raw_email=params[:raw_email]
			else
			raw_email=params[:email]	
			end
			mobile_stripped=raw_mobile.gsub(/\s+/, "")
			mobile=mobile_stripped.split(//).last(10).join
			email=raw_email.to_s
			recovery_date=params[:recovery_date]
			form_id=params[:form_id]
			campaign_id=params[:campaign_id]
			campaign_name=params[:campaign_name]
			adset_name=params[:adset_name]
			ad_name=params[:ad_name]
			adset_id=params[:adset_id]
			ad_id=params[:ad_id]
			platform=params[:platform]
			comments=''
			
			if params[:preferences_1] != nil
			comments=params[:preferences_1]
			end

			if params[:preferences_2] != nil
			comments=comments+" "+params[:preferences_2]
			end

			form_id_project_mapping=[['1682045338832481', 'JSB Springfield'],['269227544686459', 'JSB Springfield'],['554813472310466', 'JSB Springfield'],['200366628707832', 'JSB Springfield'],['1778403975683198', 'JSB Springfield'],['4330108990416268', 'JSB Springfield'],['459704068467854', 'JSB Springfield'],['2866770100304282', 'JSB Springfield'],['1341790916194513', 'JSB Lake Front'],['406098757482306', 'JSB Lake Front'],['1208873256572770', 'JSB Jyoti Residency'],['555374026255842', 'JSB Jyoti Residency'],['382787193273328', 'JSB Jyoti Residency'],['1477600535937951', 'JSB Jyoti Residency'],['1606389723082659', 'JSB Jyoti Residency'],['705825233374631', 'JSB Jyoti Residency'],['1206147023094458', 'JSB Borooah Green'],['983615398772921', 'JSB Borooah Green'],['358646553107379', 'JSB Serene Tower'],['233887495092930', 'JSB Serene Tower'],['677957192926043', 'JSB Serene Tower'],['782782955902008', 'Dream World City'],['23846156861190539', 'Dream World City'],['1108332866264783', 'Dream World City'],['759354074792904', 'Dream World City'],['669583060299276', 'Dream World City'],['249905676471062', 'Dream Palazzo'],['383245149424006', 'Dream One Hotel Apartment'],['2804548536467438', 'Dream One'],['371829807240771', 'Dream One'],['3501583783262272', 'Dream One'],['669583060299276', 'Dream One'],['1155625388153640', 'Dream World City'],['1019078571936117', 'Dream World City'],['726639751214337', 'Dream World City'],['1241734319551993', 'Dream World City'],['1017786838667586', 'Dream World City'],['783965302348964', 'Dream World City'],['2681426672106622', 'Dream One Hotel Apartment'],['784770982366625', 'Dream One Hotel Apartment'],['1108312429605219', 'Dream One Hotel Apartment'],['2913158858812604', 'Dream One Hotel Apartment'],['312762879814797', 'Dream One'],['1005528739869082', 'Dream One'],['1410755459133809', 'Dream One'],['671377870108285', 'Dream One'],['1278567955814852', 'Dream World City'],['640117449906848', 'Dream World City'],['4149848105055405', 'Dream One Hotel Apartment'],['795539567689419', 'Dream One'],['962237040891160', 'Dream One'],['371673950209680', 'Dream One'],['2344778702475868', 'Dream One'], ['1023485617836684', 'Dream World City'], ['2265455643742486', 'Dream Exotica'],['1062036224234492', 'Dream Eco City'],['743232889850383', 'Dream Eco City'],['271016487669809', 'Dream Eco City'],['592326041229427', 'Dream Eco City'],['1410073972524165', 'Dream Valley'],['298778534117416', 'Dream Valley'],['2858698247480538', 'Orchard County'],['624101314749803', 'Orchard 126'],['2452706018349685', 'Orchard 126'],['1129655463824710', 'Orchard 126']]
			if form_id_project_mapping.select{|(x, y)| x == form_id}==[]
			project_name=''	
			else	
			project_name=form_id_project_mapping.select{|(x, y)| x == form_id}[0][1]
			end
			
			facebook_ad=FacebookAd.find_by(campaign_id: campaign_id, adset_id: adset_id, ad_id: ad_id, form_id: form_id)
			if project_name==''
				if facebook_ad != nil
					project_name=facebook_ad.business_unit.name
				end
			end

			@data = ['facebook', params, organisation.name, customer_name, mobile, email, project_name, comments, params]

			project=BusinessUnit.find_by_name(project_name)
			
			# auto detection of facebook campaign
			if project==nil
				if organisation.name=='Jain Group' || organisation.name=='JSB Infrastructures' || organisation.name=='Rajat Group'
					UserMailer.api_testing_other(['facebook project not found', params, organisation.name, customer_name, mobile, email, project_name, comments, params]).deliver
					projects=organisation.business_units.pluck(:name).sort_by{|x| x.length}
					campaign_name_check=campaign_name.gsub(' ','').downcase
					business_unit_detected=''
					projects.each do |project|
						if campaign_name_check.include?(project.gsub(' ','').downcase)
							business_unit_detected=project
						end
					end
					if business_unit_detected != ''
						# UserMailer.api_testing_other(['facebook_project_found', params, organisation.name, customer_name, mobile, email, project_name, comments, params]).deliver
						detected_business_unit=BusinessUnit.find_by_name(business_unit_detected)
						fb_with_adset=FacebookAd.find_by_adset_id(adset_id)
						if fb_with_adset != nil
							ad_source_category=SourceCategory.new
							ad_source_category.organisation_id=organisation.id
							ad_source_category.description=ad_name.gsub('.','')
							ad_source_category.heirarchy=SourceCategory.find(fb_with_adset.source_category.predecessor).heirarchy+' . '+(ad_name.gsub('.',''))
							ad_source_category.predecessor=fb_with_adset.source_category.predecessor
							ad_source_category.save
							# create subsource of ad
						else
							fb_with_campaign=FacebookAd.find_by_campaign_id(campaign_id)
							if fb_with_campaign != nil
								adset_source_category=SourceCategory.new
								adset_source_category.organisation_id=organisation.id
								adset_source_category.description=adset_name.gsub('.','')
								adset_source_category.heirarchy=SourceCategory.find(SourceCategory.find(fb_with_campaign.source_category.predecessor).predecessor).heirarchy+' . '+(adset_name.gsub('.',''))
								adset_source_category.predecessor=SourceCategory.find(fb_with_campaign.source_category.predecessor).predecessor
								adset_source_category.save
								ad_source_category=SourceCategory.new
								ad_source_category.organisation_id=organisation.id
								ad_source_category.description=ad_name.gsub('.','')
								ad_source_category.heirarchy=adset_source_category.heirarchy+' . '+(ad_name.gsub('.',''))
								ad_source_category.predecessor=adset_source_category.id
								ad_source_category.save
								# create sub source of adset and sub sub source of ad
							else
								if organisation.name=='Jain Group'
								fb_source_category=SourceCategory.find_by(organisation_id: organisation.id, description: 'FACEBOOK')
								else
								fb_source_category=SourceCategory.find_by(organisation_id: organisation.id, description: 'Facebook')
								end
								campaign_source_category=SourceCategory.new
								campaign_source_category.organisation_id=organisation.id
								campaign_source_category.description=campaign_name.gsub('.','')
								campaign_source_category.heirarchy=fb_source_category.heirarchy+' . '+(campaign_name.gsub('.',''))
								campaign_source_category.predecessor=fb_source_category.id
								campaign_source_category.save
								adset_source_category=SourceCategory.new
								adset_source_category.organisation_id=organisation.id
								adset_source_category.description=adset_name.gsub('.','')
								adset_source_category.heirarchy=campaign_source_category.heirarchy+' . '+(adset_name.gsub('.',''))
								adset_source_category.predecessor=campaign_source_category.id
								adset_source_category.save
								ad_source_category=SourceCategory.new
								ad_source_category.organisation_id=organisation.id
								ad_source_category.description=ad_name.gsub('.','')
								ad_source_category.heirarchy=adset_source_category.heirarchy+' . '+(ad_name.gsub('.',''))
								ad_source_category.predecessor=adset_source_category.id
								ad_source_category.save
								# create sub, sub sub, sub sub sub, of campaign, adset, ad
							end
						end
						facebook_ad=FacebookAd.new
						facebook_ad.campaign_id=campaign_id
						facebook_ad.adset_id=adset_id
						facebook_ad.ad_id=ad_id
						facebook_ad.form_id=form_id
						facebook_ad.source_category_id=ad_source_category.id
						facebook_ad.business_unit_id=detected_business_unit.id
						facebook_ad.save
						project=detected_business_unit
						# create fbad with above particulars
						# set project
						UserMailer.api_testing_other(['facebook_campaign_created', params, organisation.name, customer_name, mobile, email, project_name, comments, params]).deliver	
					end
				end
			end						

			if project==nil
			UserMailer.api_testing_other(['facebook_project_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments, params]).deliver	
			else
			auto_lead=Lead.new

			if recovery_date != nil
			auto_lead.generated_on=recovery_date
			else
			auto_lead.generated_on=Time.now
			end
			auto_lead.name=customer_name
			auto_lead.business_unit_id=project.id
			auto_lead.platform = platform
			if organisation.name=='Jain Group'
			auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'FACEBOOK').id
				if facebook_ad != nil
					auto_lead.source_category_id=facebook_ad.source_category_id
				else
					UserMailer.api_testing_other(@data).deliver
				end
			elsif  organisation.name=='Rajat Group'
			auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Facebook').id
				if facebook_ad != nil
					auto_lead.source_category_id=facebook_ad.source_category_id
				else
					UserMailer.api_testing_other(@data).deliver
				end
			elsif  organisation.name=='JSB Infrastructures'
			auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Facebook').id
				if facebook_ad != nil
					auto_lead.source_category_id=facebook_ad.source_category_id
				else
					UserMailer.api_testing_other(@data).deliver
				end	
			else 
			auto_lead.source_category_id=SourceCategory.find_by(organisation_id: organisation.id, description: 'Facebook').id
			end
				if auto_lead.source_category_id==nil
					UserMailer.api_testing_other(['facebook_source_not_found', params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
				else
					auto_lead.email=email
					auto_lead.mobile=mobile
					auto_lead.other_number=other_number if other_number != ""
					auto_lead.customer_remarks=comments	
					if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil
					auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))
					elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil
					auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))
					elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[]
					auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
						if email==nil
						else
					auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))
						end
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
						if email==nil
						else
					auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))
						end
					elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
						if email==nil
						else
					auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
						end
					else
						if organisation.name=='Jain Group'
							if organisation.holiday==true
								auto_lead.transfer_to_back_office
							elsif organisation.auto_allocate==true || auto_lead.business_unit.auto_allocate==true
								auto_lead.transfer_to_back_office
							elsif (Time.now+5.hours+30.minutes).sunday?
								auto_lead.transfer_to_back_office
							elsif (Time.now+5.hours+30.minutes).saturday?
								if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
								auto_lead.transfer_to_back_office
								else
								auto_lead.transfer_to_back_office
								end		
							else
								if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
								auto_lead.transfer_to_back_office
								else
								auto_lead.transfer_to_back_office
								end
							end
						elsif organisation.name=='Oswal Group'
							if project_name=='Orchard 126'
							auto_lead.personnel_id=Personnel.find_by(name: 'Arindam Basu', organisation_id: organisation.id).id
							else
							auto_lead.personnel_id=Personnel.find_by(email: 'customercare@oswalgroup.net', organisation_id: organisation.id).id	
							end
						elsif organisation.name=='JSB Infrastructures'
							 if auto_lead.business_unit.name=='JSB Serene Tower'
							 auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
							 urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
							     result = HTTParty.get(urlstring,
							 :body => { :phone => '91'+(auto_lead.mobile),
							           :body => 'https://imageclassify.s3.amazonaws.com/serene+tower+creative.jpg',
							           :caption => "Hi "+(auto_lead.name)+",\n\nThank you for your interest in "+"JSB Serene Tower"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
								       :filename => 'offer.jpg'  
							           }.to_json,
							:headers => { 'Content-Type' => 'application/json' } )    
							 elsif auto_lead.business_unit.name=='JSB Jyoti Residency'
							 auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
							  urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
							      result = HTTParty.get(urlstring,
							  :body => { :phone => '91'+(auto_lead.mobile),
							            :body => 'https://imageclassify.s3.amazonaws.com/Jyoti+Residency+Creative.jpg',
							            :caption => "Hi "+(auto_lead.name)+",\n\nThank you for your interest in "+"JSB Jyoti Residency"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
								        :filename => 'offer.jpg'  
							            }.to_json,
							 :headers => { 'Content-Type' => 'application/json' } )	
							 elsif auto_lead.business_unit.name=='JSB Borooah Green' || auto_lead.business_unit.name=='JSB Lake Front'
							 auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
							 else
							 auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
							 end
						elsif organisation.name=='Rajat Group'
							if auto_lead.business_unit.name=='Southern Vista' || auto_lead.business_unit.name=='Aagaman'
							auto_lead.transfer_to_back_office
							else
							auto_lead.personnel_id=Personnel.find_by_email('medwina@rajathomes.com').id	
							end	 	
						end
					auto_lead.save
					UserMailer.new_lead_notification(auto_lead).deliver

					short_link='http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.alpha_id                 
					

					if auto_lead.mobile != nil && auto_lead.email != nil
					message="Source: Facebook, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ short_link
					elsif auto_lead.mobile != nil
					message="Source: Facebook, "+ auto_lead.name+", "+auto_lead.mobile+", "+ short_link
					elsif auto_lead.email != nil
					message="Source: Facebook, "+ auto_lead.name+", "+auto_lead.email+", "+ short_link
					end	
					if organisation.id == 1
						whatsapp_msg = "New Lead entered, details are given below:"+"\n"+"\n"+"*Lead Id:* "+auto_lead.id.to_s+"\n"+"*Name:* "+auto_lead.name.to_s+"\n"+"*Click to open:* "+short_link
						urlstring = "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
			            result = HTTParty.post(urlstring,
			              :body => { :to_number => '+91'+auto_lead.personnel.mobile.to_s,
			                        :message => whatsapp_msg,
			                        :type => "text"
			                }.to_json,
			              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
					end
					if organisation.whatsapp_instance==nil
					# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+auto_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
					# response=HTTParty.get(urlstring)
					else
						if organisation.name=='Rajat Group'
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
					                		 :message => message,	
					                          :type => "text"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
						end
					end
					
					# executive_number='91'+auto_lead.personnel.mobile
					# if auto_lead.mobile != nil && auto_lead.email != nil
					# message="Source: Facebook, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
					# elsif auto_lead.mobile != nil
					# message="Source: Facebook, "+ auto_lead.name+", "+auto_lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
					# elsif auto_lead.email != nil
					# message="Source: Facebook, "+ auto_lead.name+", "+auto_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
					# end	
					# if organisation.whatsapp_instance==nil
					# else

					# urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/"+organisation.phone_id+"/sendMessage"
					# 		  		result = HTTParty.post(urlstring,
					# 				   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
				 #                		 :message => message,	
				 #                          :type => "text"
				 #                          }.to_json,
				 #                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	

					# urlstring =  "https://eu71.chat-api.com/instance"+organisation.whatsapp_instance+"/sendMessage?token="+organisation.whatsapp_key
					# 	  		result = HTTParty.get(urlstring,
					# 			   :body => { :phone => "91"+(auto_lead.personnel.mobile),
					# 			              :body => message 
					# 			              }.to_json,
					# 			   :headers => { 'Content-Type' => 'application/json' } )
					# end

						if organisation.name == 'Jain Group' || organisation.name == 'JSB Infrastructures' || organisation.name == 'Rajat Group' || organisation.name == 'Oswal Group'
						else
						UserMailer.api_testing_other(['facebook_saved_'+organisation.name, params, organisation.name, customer_name, mobile, email, project_name, comments]).deliver	
						end
					end
				end
			end
		if organisation.name == 'Jain Group'
		# UserMailer.api_testing_other(@data).deliver
		elsif organisation.name == 'Rajat Group'
		UserMailer.api_testing_other(@data).deliver
		elsif organisation.name == 'JSB Infrastructures' || organisation.name == 'Oswal Group'	
		else
		UserMailer.api_testing_other(@data).deliver
		end
		render :nothing => true
	end

	def jaingroup_website_form_data
		if params[:project] == "Others" || params[:project] == "Which project are you interested in?"
			all_params = params
			UserMailer.other_enquiry(all_params).deliver
		else
			# apikey=kG6vgYgUqEmnHUtHX15pNQ
			apikey = params[:apikey]
			organisation = Organisation.find_by_api_key(apikey)
			# UserMailer.api_testing_other(['all_hits', params]).deliver	
			mobile = params['contact']
			name = params['name']
			if name==nil
			name=params['your-name']	
			end
			customer_remarks=params['remarks']
			
			if params['query']==nil
			else
				if customer_remarks==nil
				customer_remarks=params['query']
				else
				customer_remarks=customer_remarks+'-'+params['query']
				end
			end
			project_name=params['project']
			email=params['email']
			source_detail=params['utm_source'].to_s
			if name=='' && mobile=='' && email==''
			elsif mobile=='' && email==''
			else
				email='' if email==nil 
				@data = ['website_form', 'dwc and jsb testing with utm parameters', params, name, mobile, email, project_name]
				# UserMailer.api_testing(@data).deliver
				auto_lead=Lead.new
				auto_lead.generated_on=Time.now
				auto_lead.customer_remarks = params[:subject].to_s+params[:customer_message].to_s
				auto_lead.name=name
				project=BusinessUnit.find_by_name(project_name)
				if project==nil
					UserMailer.api_testing_other(['website_project_not_found', name, mobile, email, project_name, params]).deliver	
				else	
					auto_lead.business_unit_id=project.id
					auto_lead.source_category_id = 5243
					auto_lead.email=email
					auto_lead.mobile=mobile
					if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil
						auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))
					elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil
						auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))
					elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[]
						auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
						auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
						auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))
					elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
						auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])
					else
						auto_lead.transfer_to_back_office
						auto_lead.save
						UserMailer.new_lead_notification(auto_lead).deliver
					end
				end	
			end
			if auto_lead != nil		
				render :text => auto_lead.id.to_s
			else
				render :text => 'Lead not captured :('	
			end
		end
	end

	def website_form_data
		# apikey=kG6vgYgUqEmnHUtHX15pNQ
		apikey=params[:apikey]
		organisation=Organisation.find_by_api_key(apikey)
		# UserMailer.api_testing_other(['all_hits', params]).deliver	
		mobile=params['contact']
		name=params['name']
		if name==nil
			name=params['your-name']	
		end
		customer_remarks=params['remarks']
		if params['query']==nil
		else
			if customer_remarks==nil
				customer_remarks=params['query']
			else
				customer_remarks=customer_remarks+'-'+params['query']
			end
		end
		project_name=params['project']
		email=params['email']
		source_detail=params['utm_source'].to_s
		utm_campaign=params['utm_campaign']
		utm_medium=params['utm_medium']
		utm_content=params['utm_content']
		utm_term=params['utm_term']
		medium_of_communication=params['utm_form_name']
		agency=params['agency']
		# params = params.to_s
		if name=='' && mobile=='' && email==''
		elsif mobile=='' && email==''
		else
			email='' if email==nil 
			@data = ['website_form', 'dwc and jsb testing with utm parameters', params, name, mobile, email, project_name]
			# UserMailer.api_testing(@data).deliver
			auto_lead=Lead.new
			auto_lead.generated_on=Time.now
			auto_lead.customer_remarks=customer_remarks
			auto_lead.name=name
			project=BusinessUnit.find_by_name(project_name)
			if project==nil
				UserMailer.api_testing_other(['website_project_not_found', name, mobile, email, project_name, params]).deliver	
			else	
				auto_lead.business_unit_id=project.id
				if organisation.name=='JSB Infrastructures'
					if agency=='internal_campaign'
						auto_lead.source_category_id=3755
					else
						auto_lead.source_category_id=3756
					end
				elsif organisation.name=='Rajat Group'
					if source_detail.include? 'Display'
						auto_lead.source_category_id=1170
					elsif source_detail.include? 'Search'
						auto_lead.source_category_id=1169
					elsif source_detail.include? 'bing'	
						if utm_campaign.to_s.include? 'Search'
							auto_lead.source_category_id=3427	
						elsif utm_campaign.to_s.include? 'Remarketing'
							auto_lead.source_category_id=3428
						else
							auto_lead.source_category_id=3426	
						end
					elsif source_detail.include? 'Facebook'
						if utm_campaign.to_s.include? 'Remarketing'
							auto_lead.source_category_id=3424	
						else
							auto_lead.source_category_id=3423	
						end
					elsif source_detail.include? 'facebook'
						if utm_campaign.to_s.include? 'remarketing'
							auto_lead.source_category_id=3424	
						else
							auto_lead.source_category_id=3423	
						end	
					else
						auto_lead.source_category_id=1161	
					end 
				elsif organisation.name=='Oswal Group'
					if source_detail.include? 'gdn'
						auto_lead.source_category_id=658
					elsif source_detail.include? 'search'
						auto_lead.source_category_id=658
					else	
						auto_lead.source_category_id=659
					end							
				else
					if source_detail.include? 'gdn'
						auto_lead.source_category_id=1069
					elsif source_detail.include? 'search'
						auto_lead.source_category_id=1067
					elsif source_detail.include? 'Facebook'
						auto_lead.source_category_id = 5232
					elsif source_detail.include? 'abp'
						auto_lead.source_category_id = 6123	
					elsif source_detail.include? 'taboola'
						auto_lead.source_category_id = 6126	
					elsif source_detail.include? 'Adgebra'
						auto_lead.source_category_id = 6125	
					elsif source_detail.include? 'outbrain'
						auto_lead.source_category_id = 6127	
					elsif source_detail.include? 'colombia'
						auto_lead.source_category_id = 6128	
					elsif source_detail.include? 'zemanta'
						auto_lead.source_category_id = 6129	
					elsif source_detail.include? '24ghanta'
						auto_lead.source_category_id = 6124
					elsif source_detail.include? 'NewsPaper'
						auto_lead.source_category_id = 1
					elsif source_detail.include? 'Discovery'
						auto_lead.source_category_id = 6199	
					elsif source_detail.include? 'affiliate'
						auto_lead.source_category_id = 6235	
					else	
						auto_lead.source_category_id=1058
					end
				end
				if auto_lead.source_category_id==nil
					UserMailer.api_testing_other(['website_source_not_found', name, mobile, email, project_name]).deliver	
				else
					auto_lead.email=email
					auto_lead.mobile=mobile

					if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil
						auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						if medium_of_communication==nil
							google_lead_detail.communicated_through = 'Form'
						else
							google_lead_detail.communicated_through = medium_of_communication	
						end
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.network = params[:network]
						google_lead_detail.campaignid = params[:campaign_id]
						google_lead_detail.adgroupid = params[:adgroup_id]
						google_lead_detail.gclid = params[:gclid]
						google_lead_detail.fbclid = params[:fbclid]
						google_lead_detail.device = params[:device]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.target = params[:target]
						google_lead_detail.target_id = params[:target_id]
						google_lead_detail.loc_interest_ms = params[:loc_interest_ms]
						google_lead_detail.loc_physical_ms = params[:loc_physical_ms]
						google_lead_detail.device_model = params[:device_model]
						google_lead_detail.source_id = params[:source_id]
						google_lead_detail.placement = params[:placement]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.adposition = params[:adposition]
						google_lead_detail.keyword = params[:keyword]
						google_lead_detail.match_type = params[:match_type]
						google_lead_detail.extention_id = params[:extension_id]
						google_lead_detail.save
					elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil
						auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						if medium_of_communication==nil
							google_lead_detail.communicated_through = 'Form'
						else
							google_lead_detail.communicated_through = medium_of_communication	
						end
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.network = params[:network]
						google_lead_detail.campaignid = params[:campaign_id]
						google_lead_detail.adgroupid = params[:adgroup_id]
						google_lead_detail.gclid = params[:gclid]
						google_lead_detail.fbclid = params[:fbclid]
						google_lead_detail.device = params[:device]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.target = params[:target]
						google_lead_detail.target_id = params[:target_id]
						google_lead_detail.loc_interest_ms = params[:loc_interest_ms]
						google_lead_detail.loc_physical_ms = params[:loc_physical_ms]
						google_lead_detail.device_model = params[:device_model]
						google_lead_detail.source_id = params[:source_id]
						google_lead_detail.placement = params[:placement]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.adposition = params[:adposition]
						google_lead_detail.keyword = params[:keyword]
						google_lead_detail.match_type = params[:match_type]
						google_lead_detail.extention_id = params[:extension_id]
						google_lead_detail.save
					elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[]
						auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						if medium_of_communication==nil
							google_lead_detail.communicated_through = 'Form'
						else
							google_lead_detail.communicated_through = medium_of_communication	
						end
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.network = params[:network]
						google_lead_detail.campaignid = params[:campaign_id]
						google_lead_detail.adgroupid = params[:adgroup_id]
						google_lead_detail.gclid = params[:gclid]
						google_lead_detail.fbclid = params[:fbclid]
						google_lead_detail.device = params[:device]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.target = params[:target]
						google_lead_detail.target_id = params[:target_id]
						google_lead_detail.loc_interest_ms = params[:loc_interest_ms]
						google_lead_detail.loc_physical_ms = params[:loc_physical_ms]
						google_lead_detail.device_model = params[:device_model]
						google_lead_detail.source_id = params[:source_id]
						google_lead_detail.placement = params[:placement]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.adposition = params[:adposition]
						google_lead_detail.keyword = params[:keyword]
						google_lead_detail.match_type = params[:match_type]
						google_lead_detail.extention_id = params[:extension_id]
						google_lead_detail.save
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
						auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						if medium_of_communication==nil
							google_lead_detail.communicated_through = 'Form'
						else
							google_lead_detail.communicated_through = medium_of_communication	
						end
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.network = params[:network]
						google_lead_detail.campaignid = params[:campaign_id]
						google_lead_detail.adgroupid = params[:adgroup_id]
						google_lead_detail.gclid = params[:gclid]
						google_lead_detail.fbclid = params[:fbclid]
						google_lead_detail.device = params[:device]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.target = params[:target]
						google_lead_detail.target_id = params[:target_id]
						google_lead_detail.loc_interest_ms = params[:loc_interest_ms]
						google_lead_detail.loc_physical_ms = params[:loc_physical_ms]
						google_lead_detail.device_model = params[:device_model]
						google_lead_detail.source_id = params[:source_id]
						google_lead_detail.placement = params[:placement]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.adposition = params[:adposition]
						google_lead_detail.keyword = params[:keyword]
						google_lead_detail.match_type = params[:match_type]
						google_lead_detail.extention_id = params[:extension_id]
						google_lead_detail.save
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
						auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						if medium_of_communication==nil
							google_lead_detail.communicated_through = 'Form'
						else
							google_lead_detail.communicated_through = medium_of_communication	
						end
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.network = params[:network]
						google_lead_detail.campaignid = params[:campaign_id]
						google_lead_detail.adgroupid = params[:adgroup_id]
						google_lead_detail.gclid = params[:gclid]
						google_lead_detail.fbclid = params[:fbclid]
						google_lead_detail.device = params[:device]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.target = params[:target]
						google_lead_detail.target_id = params[:target_id]
						google_lead_detail.loc_interest_ms = params[:loc_interest_ms]
						google_lead_detail.loc_physical_ms = params[:loc_physical_ms]
						google_lead_detail.device_model = params[:device_model]
						google_lead_detail.source_id = params[:source_id]
						google_lead_detail.placement = params[:placement]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.adposition = params[:adposition]
						google_lead_detail.keyword = params[:keyword]
						google_lead_detail.match_type = params[:match_type]
						google_lead_detail.extention_id = params[:extension_id]
						google_lead_detail.save
					elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
						auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						if medium_of_communication==nil
							google_lead_detail.communicated_through = 'Form'
						else
							google_lead_detail.communicated_through = medium_of_communication	
						end
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.network = params[:network]
						google_lead_detail.campaignid = params[:campaign_id]
						google_lead_detail.adgroupid = params[:adgroup_id]
						google_lead_detail.gclid = params[:gclid]
						google_lead_detail.fbclid = params[:fbclid]
						google_lead_detail.device = params[:device]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.target = params[:target]
						google_lead_detail.target_id = params[:target_id]
						google_lead_detail.loc_interest_ms = params[:loc_interest_ms]
						google_lead_detail.loc_physical_ms = params[:loc_physical_ms]
						google_lead_detail.device_model = params[:device_model]
						google_lead_detail.source_id = params[:source_id]
						google_lead_detail.placement = params[:placement]
						google_lead_detail.creative = params[:creative]
						google_lead_detail.adposition = params[:adposition]
						google_lead_detail.keyword = params[:keyword]
						google_lead_detail.match_type = params[:match_type]
						google_lead_detail.extention_id = params[:extension_id]
						google_lead_detail.save
					else
						if organisation.name=='JSB Infrastructures'
							if auto_lead.business_unit.name=='JSB Serene Tower'
							 	auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
							 	urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
							     result = HTTParty.get(urlstring,
							 		:body => { :phone => '91'+(auto_lead.mobile),
							           :body => 'https://imageclassify.s3.amazonaws.com/serene+tower+creative.jpg',
							           :caption => "Hi "+(auto_lead.name)+",\n\nThank you for your interest in "+"JSB Serene Tower"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
							           :filename => 'offer.jpg'  
							           }.to_json,
								:headers => { 'Content-Type' => 'application/json' } )    
							elsif auto_lead.business_unit.name=='JSB Borooah Green' || auto_lead.business_unit.name=='JSB Lake Front'
								auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
							  	urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
							      result = HTTParty.get(urlstring,
							  	:body => { :phone => '91'+(auto_lead.mobile),
							            :body => 'https://imageclassify.s3.amazonaws.com/Jyoti+Residency+Creative.jpg',
							            :caption => "Hi "+(auto_lead.name)+",\n\nThank you for your interest in "+"JSB Jyoti Residency"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
							           	:filename => 'offer.jpg'  
							            }.to_json,
							 	:headers => { 'Content-Type' => 'application/json' } )	
							else
							 	auto_lead.personnel_id=Personnel.find_by(name: 'Namrata Bhattacharya', organisation_id: organisation.id).id
							  	urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
							      result = HTTParty.get(urlstring,
							  	:body => { :phone => '91'+(auto_lead.mobile),
							            :body => 'https://imageclassify.s3.amazonaws.com/Jyoti+Residency+Creative.jpg',
							            :caption => "Hi "+(auto_lead.name)+",\n\nThank you for your interest in "+"JSB Jyoti Residency"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
							           	:filename => 'offer.jpg'  
							            }.to_json,
							 	:headers => { 'Content-Type' => 'application/json' } )	
							end
						elsif organisation.name=='Rajat Group'
							if project_name=='Southern Vista' || project_name=='Aagaman'
								auto_lead.transfer_to_back_office
							else
								auto_lead.personnel_id=Personnel.find_by_email('medwina@rajathomes.com').id	
							end
						elsif organisation.name=='Oswal Group'
							auto_lead.personnel_id==Personnel.find_by(email: 'customercare@oswalgroup.net', organisation_id: organisation.id).id	
						else
							auto_lead.transfer_to_back_office
						end
						auto_lead.save
						UserMailer.new_lead_notification(auto_lead).deliver

						google_lead_detail=GoogleLeadDetail.new
						google_lead_detail.lead_id=auto_lead.id
						if medium_of_communication==nil
							google_lead_detail.communicated_through='Form'
						else
							google_lead_detail.communicated_through=medium_of_communication	
						end
						google_lead_detail.utm_source=source_detail
						google_lead_detail.utm_campaign=utm_campaign
						google_lead_detail.utm_medium=utm_medium
						google_lead_detail.utm_content=utm_content
						google_lead_detail.utm_term=utm_term
						google_lead_detail.network=params[:network]
						google_lead_detail.campaignid=params[:campaign_id]
						google_lead_detail.adgroupid=params[:adgroup_id]
						google_lead_detail.gclid=params[:gclid]
						google_lead_detail.fbclid=params[:fbclid]
						google_lead_detail.device=params[:device]
						google_lead_detail.creative=params[:creative]
						google_lead_detail.target=params[:target]
						google_lead_detail.target_id=params[:target_id]
						google_lead_detail.loc_interest_ms=params[:loc_interest_ms]
						google_lead_detail.loc_physical_ms=params[:loc_physical_ms]
						google_lead_detail.device_model=params[:device_model]
						google_lead_detail.source_id=params[:source_id]
						google_lead_detail.placement=params[:placement]
						google_lead_detail.creative=params[:creative]
						google_lead_detail.adposition=params[:adposition]
						google_lead_detail.keyword=params[:keyword]
						google_lead_detail.match_type=params[:match_type]
						google_lead_detail.extention_id=params[:extension_id]
						google_lead_detail.save

						short_link='http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.alpha_id
						if auto_lead.mobile != nil && auto_lead.email != nil
							message="Source: Google, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ short_link
						elsif auto_lead.mobile != nil
							message="Source: Google, "+ auto_lead.name+", "+auto_lead.mobile+", "+ short_link
						elsif auto_lead.email != nil
							message="Source: Google, "+ auto_lead.name+", "+auto_lead.email+", "+ short_link
						end	
						if organisation.id == 1
							whatsapp_msg = "New Lead entered, details are given below:"+"\n"+"\n"+"*Lead Id:* "+auto_lead.id.to_s+"\n"+"*Name:* "+auto_lead.name.to_s+"\n"+"*Click to open:* "+short_link
							urlstring = "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
				            result = HTTParty.post(urlstring,
				              :body => { :to_number => '+91'+auto_lead.personnel.mobile.to_s,
				                        :message => whatsapp_msg,
				                        :type => "text"
				                }.to_json,
				              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
						end
						if organisation.whatsapp_instance==nil
							# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+auto_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
							# response=HTTParty.get(urlstring)
						else
							if organisation.name=='Rajat Group'
								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
						  		result = HTTParty.post(urlstring,
								   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
			                		 :message => message,	
			                          :type => "text"
			                          }.to_json,
			                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
							end
						end
						# executive_number='91'+auto_lead.personnel.mobile
						# if auto_lead.mobile != nil && auto_lead.email != nil
						# message="Source: Website, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
						# elsif auto_lead.mobile != nil
						# message="Source: Website, "+ auto_lead.name+", "+auto_lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
						# elsif auto_lead.email != nil
						# message="Source: Website, "+ auto_lead.name+", "+auto_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
						# end
						# if organisation.whatsapp_instance==nil	
						# else

						# urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/"+organisation.phone_id+"/sendMessage"
						#   		result = HTTParty.post(urlstring,
						# 		   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
			   #              		 :message => message,	
			   #                        :type => "text"
			   #                        }.to_json,
			   #                        :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	


						# urlstring =  "https://eu71.chat-api.com/instance"+organisation.whatsapp_instance+"/sendMessage?token="+organisation.whatsapp_key
						# 	  		result = HTTParty.get(urlstring,
						# 			   :body => { :phone => "91"+(auto_lead.personnel.mobile),
						# 			              :body => message 
						# 			              }.to_json,
						# 			   :headers => { 'Content-Type' => 'application/json' } )
							
						# end
						# UserMailer.api_testing_other(['website_lead saved', name, mobile, email, project_name, params]).deliver	
					end
				end
			end	
		end
		if auto_lead != nil		
			render :text => auto_lead.id.to_s
		else
			render :text => 'Lead not captured :('	
		end
	end

	def website_chat_data
		# apikey=kG6vgYgUqEmnHUtHX15pNQ
		apikey=params[:apikey]
		organisation=Organisation.find_by_api_key(apikey)
		# UserMailer.api_testing_other(['website chat', params]).deliver	
		mobile=params['mobile']
		name=params['name']
		project_name=params['project']
		email=params['email']
		remarks=params['remarks']
		chat_link=params['chat_link']
		remarks=(remarks.to_s)+(chat_link.to_s)
		source_detail=params['utm_source'].to_s
		agency=params['agency']
		utm_campaign=params['utm_campaign']
		utm_medium=params['utm_medium']
		utm_content=params['utm_content']
		utm_term=params['utm_term']
		# params = params.to_s
		if name=='' && mobile=='' && email==''
		elsif mobile=='' && email==''
		else
			email='' if email==nil 
			@data = ['website_chat', 'chat testing with utm parameters', params, name, mobile, email, project_name]
			# UserMailer.api_testing(@data).deliver
			auto_lead=Lead.new
			auto_lead.generated_on=Time.now
			if name==nil
				auto_lead.name='Not Available'
			else
				auto_lead.name=name
			end
			auto_lead.customer_remarks=remarks
			project=BusinessUnit.find_by_name(project_name)
			if project==nil
				UserMailer.api_testing_other(['website_chat_project_not_found', name, mobile, email, project_name, params]).deliver	
			else	
				auto_lead.business_unit_id=project.id
				
				if agency==nil
					if source_detail.include? 'gdn'
					auto_lead.source_category_id=1070
					elsif source_detail.include? 'search'
					auto_lead.source_category_id=1066
					else	
					auto_lead.source_category_id=1059
					end
				elsif agency=='first'
					if source_detail.include? 'gdn'
					auto_lead.source_category_id=1070
					elsif source_detail.include? 'search'
					auto_lead.source_category_id=1066
					else	
					auto_lead.source_category_id=1059
					end
				elsif agency=='second'
					if source_detail.include? 'gdn'
					auto_lead.source_category_id=1525
					elsif source_detail.include? 'search'
					auto_lead.source_category_id=1521
					else	
					auto_lead.source_category_id=1523
					end
				elsif agency=='third'
					if source_detail.include? 'gdn'
					auto_lead.source_category_id=1617
					elsif source_detail.include? 'search'
					auto_lead.source_category_id=1615
					else	
					auto_lead.source_category_id=1619
					end
				else
					if source_detail.include? 'gdn'
					auto_lead.source_category_id=1070
					elsif source_detail.include? 'search'
					auto_lead.source_category_id=1066
					else	
					auto_lead.source_category_id=1059
					end
				end						
				if auto_lead.source_category_id==nil
					UserMailer.api_testing_other(['website_chat_source_not_found', name, mobile, email, project_name]).deliver	
				else
					auto_lead.email=email
					auto_lead.mobile=mobile
					if Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false)!=nil
						auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: false))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						google_lead_detail.communicated_through = 'Chat'
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.save
					elsif Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil)!=nil
						auto_lead.duplicate_capture(Lead.find_by(mobile: mobile, business_unit_id: project.id, status: nil))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						google_lead_detail.communicated_through = 'Chat'
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.save
					elsif Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[]
						auto_lead.duplicate_capture(Lead.where(mobile: mobile, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						google_lead_detail.communicated_through = 'Chat'
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.save
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: false)!=nil && email != ''
						auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: false))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						google_lead_detail.communicated_through = 'Chat'
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.save
					elsif Lead.find_by(email: email, business_unit_id: project.id, status: nil)!=nil && email != ''
						auto_lead.duplicate_capture(Lead.find_by(email: email, business_unit_id: project.id, status: nil))

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						google_lead_detail.communicated_through = 'Chat'
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.save
					elsif Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)!=[] && email != ''
						auto_lead.duplicate_capture(Lead.where(email: email, business_unit_id: project.id, status: true).where('created_at > ?', Date.today-7.days)[0])

						google_lead_detail = GoogleLeadDetail.new
						google_lead_detail.lead_id = auto_lead.id
						google_lead_detail.communicated_through = 'Chat'
						google_lead_detail.utm_source = source_detail
						google_lead_detail.utm_campaign = utm_campaign
						google_lead_detail.utm_medium = utm_medium
						google_lead_detail.utm_content = utm_content
						google_lead_detail.utm_term = utm_term
						google_lead_detail.save
					else
						auto_lead.transfer_to_back_office
						auto_lead.save
						UserMailer.new_lead_notification(auto_lead).deliver

						google_lead_detail=GoogleLeadDetail.new
						google_lead_detail.lead_id=auto_lead.id
						google_lead_detail.communicated_through='Chat'
						google_lead_detail.utm_source=source_detail
						google_lead_detail.utm_campaign=utm_campaign
						google_lead_detail.utm_medium=utm_medium
						google_lead_detail.utm_content=utm_content
						google_lead_detail.utm_term=utm_term
						google_lead_detail.save

						# executive_number='91'+auto_lead.personnel.mobile
						# if auto_lead.mobile != nil && auto_lead.email != nil
						# message="Source: Website Chat, "+ auto_lead.name+", "+auto_lead.mobile+", "+auto_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
						# elsif auto_lead.mobile != nil
						# message="Source: Website Chat, "+ auto_lead.name+", "+auto_lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
						# elsif auto_lead.email != nil
						# message="Source: Website Chat, "+ auto_lead.name+", "+auto_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+auto_lead.id.to_s).short_url
						# end
						# if organisation.whatsapp_instance==nil	
						# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+auto_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
						# response=HTTParty.get(urlstring)
						# else

						# urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/"+organisation.phone_id+"/sendMessage"
						#   		result = HTTParty.post(urlstring,
						# 		   :body => { :to_number => "+91"+(auto_lead.personnel.mobile),
			   #              		 :message => message,	
			   #                        :type => "text"
			   #                        }.to_json,
			   #                        :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	


							
						# end
						# UserMailer.api_testing_other(['website_lead saved', name, mobile, email, project_name, params]).deliver	
					end
				end
			end	
		end		
		render :nothing => true
	end

	def jsb_calls
		# UserMailer.api_testing_other(['j call details', 'test', 'JSB Infrastructures', params]).deliver
		
		ivr_number=params['vmn']
		ivr_number=ivr_number.gsub(/\s+/, "")
		mobile=params['caller_number']
		duration=params['callduration']
		date=params['date']
		time=params['time']
		personnel_mobile=params['agentno']
		personnel_mobile=personnel_mobile.gsub(/\s+/, "")
		personnel_mobile=personnel_mobile.split(//).last(10).join
		call_url=params['callrec']
		state=params['state']
		status=params['callstatus']
		if status != 'MISSED'
		personnel=Personnel.where(mobile: personnel_mobile).where.not(access_right: -1)[0]
		end

		# UserMailer.api_testing_other(['j call details params test', 'test', 'JSB Infrastructures', params, ivr_number]).deliver
		

		if ivr_number=='7086000000'
		business_unit_ids=BusinessUnit.where(name: ['JSB Serene Tower','JSB Jyoti Residency']).pluck(:id)
			lead=Lead.where(mobile: mobile, business_unit_id: business_unit_ids, booked_on: nil)
			if lead==[]
				lead=Lead.new
				lead.mobile=mobile
				lead.business_unit_id=BusinessUnit.find_by_name('JSB Serene Tower').id
				lead.generated_on=(date+' '+time).to_datetime
				lead.source_category_id=4208
				lead.name='IVR - '+status+' '+mobile
				if personnel==nil
					lead.transfer_to_back_office
				else
					lead.personnel_id=personnel.id
				end
				lead.save
			else
				lead=lead[0]
			end
		elsif ivr_number=='6026000000'
		business_unit_ids=BusinessUnit.where(name: ['JSB Springfield','JSB Lake Front']).pluck(:id)
			lead=Lead.where(mobile: mobile, business_unit_id: business_unit_ids, booked_on: nil)
			if lead==[]
				lead=Lead.new
				lead.mobile=mobile
				lead.business_unit_id=BusinessUnit.find_by_name('JSB Springfield').id
				lead.generated_on=(date+' '+time).to_datetime
				lead.source_category_id=4208
				lead.name='IVR - '+status+' '+mobile
				if personnel==nil
					lead.transfer_to_back_office
				else
					lead.personnel_id=personnel.id
				end
				lead.save
			else
				lead=lead[0]
			end
		end

		if lead != nil && duration != '0'
			call_record=CallRecord.new
			call_record.lead_id=lead.id
			if personnel != nil
			call_record.personnel_id=personnel.id
			else
			call_record.personnel_id=lead.personnel_id	
			end
			call_record.url=call_url
			call_record.occurred_at=(date+' '+time).to_datetime
			call_record.call_length=duration.to_i
			call_record.save
		end
		render text: 'successfully captured'
	end




	def calls
		# recall by previous lead

		@sr=params[:dispnumber]
		@lead_number=params[:caller_id]
		@call_id=params[:callid]
		@start_time=params[:start_time]
		@end_time=params[:end_time]
		@destination=params[:destination]


		if MarketingNumber.find_by_number(@sr) != nil
			@marketing_number_id=MarketingNumber.find_by_number(@sr).id
			@call=Call.new
			@call.marketing_number_id=@marketing_number_id
			@call.number_id=@call_id
			@call.number=@lead_number
			if @start_time==nil
			else
			@call.start_time=@start_time.to_datetime
			@call.end_time=@end_time.to_datetime
			end
			if @destination=='Missed Call'
				@call.nature=true
				@call.personnel_id=0
			elsif @destination=='Call Missed'
				@call.nature=false
				@call.personnel_id=0
			elsif @destination=='User Disconnected'
				@call.personnel_id=0
			else
				@destination = @destination[3..12]
				if Personnel.find_by(mobile: @destination, access_right: nil)!=nil
					@call.personnel_id=Personnel.find_by(mobile: @destination, access_right: nil).id	
				elsif Personnel.find_by(mobile: @destination, access_right: 2)!=nil
					@call.personnel_id=Personnel.find_by(mobile: @destination, access_right: 2).id
				elsif Personnel.find_by(mobile: @destination, access_right: 1)!=nil
					@call.personnel_id=Personnel.find_by(mobile: @destination, access_right: 1).id	
				elsif Personnel.find_by(mobile: @destination, access_right: 0)!=nil
					@call.personnel_id=Personnel.find_by(mobile: @destination, access_right: 0).id	
				elsif Personnel.find_by(business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, access_right: 2)!=nil
					@call.personnel_id=Personnel.find_by(business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, access_right: 2).id
				elsif Personnel.find_by(business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, access_right: nil)!=nil
					@call.personnel_id=Personnel.find_by(business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, access_right: nil).id
				else 
					@call.personnel_id=Personnel.find_by(organisation_id: 1, access_right: 2).id
				end
			end 		 		
			@call.save
			organisation=Organisation.find(MarketingNumber.find_by_number(@sr).organisation_id)
			@data=[@sr, @call_id, @lead_number, @start_time, @end_time, @destination, params]
			# UserMailer.api_testing(@data).deliver
		
			
				if Lead.joins(:personnel).where(:personnels => {organisation_id: MarketingNumber.find_by_number(@sr).organisation_id}, :leads => {mobile: @call.number[3..12], business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, status: false}) != []
				puts 'duplicate'
				elsif Lead.joins(:personnel).where(:personnels => {organisation_id: MarketingNumber.find_by_number(@sr).organisation_id}, :leads => {mobile: @call.number[3..12], business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, status: nil}) != []	
				puts 'duplicate'
				else	
					  
					@lead=Lead.new
					@lead.name=@sr+' - '+ @destination
					@lead.mobile=@call.number[3..12]
					@lead.business_unit_id=MarketingNumber.find_by_number(@sr).business_unit_id
					if BusinessUnit.find_by_name('Southern Vista').id==@lead.business_unit_id
					@lead.source_category_id=1189
					@lead.personnel_id=Personnel.find_by_email('csaurav@rajathomes.com').id
					else
						@lead.source_category_id=868
						if @call.personnel_id!=0
						@lead.transfer_to_back_office	
						@lead.personnel_id=@call.personnel_id
						else
							
								if organisation.holiday==true
									@lead.transfer_to_back_office
								elsif organisation.auto_allocate==true || @lead.business_unit.auto_allocate==true
									@lead.transfer_to_back_office
								elsif (Time.now+5.hours+30.minutes).sunday?
									@lead.transfer_to_back_office
								elsif (Time.now+5.hours+30.minutes).saturday?
									if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
									@lead.transfer_to_back_office
									else
									@lead.transfer_to_back_office
									end		
								else
									if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
									@lead.transfer_to_back_office
									else
									@lead.transfer_to_back_office
									end
								end
						end
					end	
					@lead.generated_on = Time.now
					# @lead.nature = 1
					# @lead.nature_id = @call.id
					@lead.save
					UserMailer.new_lead_notification(@lead).deliver
					if organisation.id == 1
						whatsapp_msg = "New Lead entered, details are given below:"+"\n"+"\n"+"*Lead Id:* "+@lead.id.to_s+"\n"+"*Name:* "+@lead.name.to_s+"\n"
						urlstring = "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
			            result = HTTParty.post(urlstring,
			              :body => { :to_number => '+91'+@lead.personnel.mobile.to_s,
			                        :message => whatsapp_msg,
			                        :type => "text"
			                }.to_json,
			              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
					end
					# executive_number='91'+@lead.personnel.mobile
					# if @lead.mobile != nil && @lead.email != nil
					# message="Through: Super Receptionist, "+ @lead.name+", 0"+@lead.mobile+", "+@lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+@lead.id.to_s).short_url
					# elsif @lead.mobile != nil
					# message="Through: Super Receptionist, "+ @lead.name+", 0"+@lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+@lead.id.to_s).short_url
					# elsif @lead.email != nil
					# message="Source: Super Receptionist, "+ @lead.name+", "+@lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+@lead.id.to_s).short_url
					# end

					# if organisation.whatsapp_instance==nil
					# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
					# response=HTTParty.get(urlstring)
					# else

					# urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/"+organisation.phone_id+"/sendMessage"
					# 		  		result = HTTParty.post(urlstring,
					# 				   :body => { :to_number => "+91"+(@lead.personnel.mobile),
				 #                		 :message => message,	
				 #                          :type => "text"
				 #                          }.to_json,
				 #                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
	

					# end
				end
		else
		 	UserMailer.api_testing(@data).deliver	
	 	end
		render :nothing => true
	end

	def rajat_calls
		# recall by previous lead

		@sr=params[:dispnumber]
		@lead_number=params[:caller_id]
		@call_id=params[:callid]
		@start_time=params[:start_time]
		@end_time=params[:end_time]
		@destination=params[:destination]


		if MarketingNumber.find_by_number(@sr) != nil
			@marketing_number_id=MarketingNumber.find_by_number(@sr).id
			@call=Call.new
			@call.marketing_number_id=@marketing_number_id
			@call.number_id=@call_id
			@call.number=@lead_number
			@call.start_time=@start_time.to_datetime
			@call.end_time=@end_time.to_datetime
			if @destination=='Missed Call'
				@call.nature=true
				@call.personnel_id=0
			elsif @destination=='Call Missed'
				@call.nature=false
				@call.personnel_id=0
			elsif @destination=='User Disconnected'
				@call.personnel_id=0
			else
				@destination = @destination[3..12]
				if Personnel.find_by(mobile: @destination, access_right: nil)!=nil
					@call.personnel_id=Personnel.find_by(mobile: @destination, access_right: nil).id	
				elsif Personnel.find_by(mobile: @destination, access_right: 2)!=nil
					@call.personnel_id=Personnel.find_by(mobile: @destination, access_right: 2).id
				elsif Personnel.find_by(mobile: @destination, access_right: 1)!=nil
					@call.personnel_id=Personnel.find_by(mobile: @destination, access_right: 1).id	
				else
					@call.personnel_id=Personnel.find_by(organisation_id: 7, access_right: nil).id
				end
			end 		 		
			@call.save
			organisation=Organisation.find(MarketingNumber.find_by_number(@sr).organisation_id)
			@data=[@sr, @call_id, @lead_number, @start_time, @end_time, @destination]
		
			
				if Lead.joins(:personnel).where(:personnels => {organisation_id: MarketingNumber.find_by_number(@sr).organisation_id}, :leads => {mobile: @call.number[3..12], business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, status: false}) != []
				puts 'duplicate'
				elsif Lead.joins(:personnel).where(:personnels => {organisation_id: MarketingNumber.find_by_number(@sr).organisation_id}, :leads => {mobile: @call.number[3..12], business_unit_id: MarketingNumber.find_by_number(@sr).business_unit_id, status: nil}) != []	
				puts 'duplicate'
				else	
					  
					@lead=Lead.new
					@lead.name=@sr+' - '+ @destination
					@lead.mobile=@call.number[3..12]
					@lead.business_unit_id=MarketingNumber.find_by_number(@sr).business_unit_id
					if BusinessUnit.find_by_name('Southern Vista').id==@lead.business_unit_id
						if @call.personnel_id!=0
						@lead.personnel_id=@call.personnel_id	
						else
						@lead.transfer_to_back_office
						end
						if @sr=='+919696066066'	
						@lead.source_category_id=1189
						elsif @sr=='+918929568808'
						@lead.source_category_id=1161
						else
						@lead.source_category_id=3362
						end
					else
						if @call.personnel_id!=0
						@lead.transfer_to_back_office	
						@lead.personnel_id=@call.personnel_id
						else
							
								if organisation.holiday==true
									@lead.transfer_to_back_office
								elsif organisation.auto_allocate==true || @lead.business_unit.auto_allocate==true
									@lead.transfer_to_back_office
								elsif (Time.now+5.hours+30.minutes).sunday?
									@lead.transfer_to_back_office
								elsif (Time.now+5.hours+30.minutes).saturday?
									if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
									@lead.transfer_to_back_office
									else
									@lead.transfer_to_back_office
									end		
								else
									if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
									@lead.transfer_to_back_office
									else
									@lead.transfer_to_back_office
									end
								end
						end
					@lead.source_category_id=1189
					end
					@lead.generated_on = Time.now
					# @lead.nature = 1
					# @lead.nature_id = @call.id
					@lead.save
					UserMailer.new_lead_notification(@lead).deliver

					# executive_number='91'+@lead.personnel.mobile
					# if @lead.mobile != nil && @lead.email != nil
					# message="Through: Super Receptionist, "+ @lead.name+", 0"+@lead.mobile+", "+@lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+@lead.id.to_s).short_url
					# elsif @lead.mobile != nil
					# message="Through: Super Receptionist, "+ @lead.name+", 0"+@lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+@lead.id.to_s).short_url
					# elsif @lead.email != nil
					# message="Source: Super Receptionist, "+ @lead.name+", "+@lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+@lead.id.to_s).short_url
					# end

					# if organisation.whatsapp_instance==nil
					# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
					# response=HTTParty.get(urlstring)
					# else

					# urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/"+organisation.phone_id+"/sendMessage"
					# 		  		result = HTTParty.post(urlstring,
					# 				   :body => { :to_number => "+91"+(@lead.personnel.mobile),
				 #                		 :message => message,	
				 #                          :type => "text"
				 #                          }.to_json,
				 #                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
	

					# end
				end
		else
		 	UserMailer.api_testing(@data).deliver	
	 	end
		render :nothing => true
	end

	def fb_whatsapp_lead_create
		mobile=params[:mobile]
		project=params[:project]

		project_id=BusinessUnit.find_by_name(project).id

		if Lead.find_by(mobile: mobile, business_unit_id: project_id, status: false)!=nil
		UserMailer.api_testing_other(['fb_mobile_duplicate', params, 'Jain Group']).deliver	
		elsif Lead.find_by(mobile: mobile, business_unit_id: project_id, status: nil)!=nil
		UserMailer.api_testing_other(['fb_mobile_duplicate', params, 'Jain Group']).deliver	
		elsif Lead.where(mobile: mobile, business_unit_id: project_id, status: true).where('created_at > ?', Date.today-7.days)!=[]
		UserMailer.api_testing_other(['fb_mobile_duplicate_lost_last_7_days', params, 'Jain Group']).deliver	
		else
			lead=Lead.new
			lead.mobile=params[:mobile]
			lead.business_unit_id=BusinessUnit.find_by_name(project).id
			lead.source_category_id=37
			lead.name='FB Whatsapp -'+mobile
			lead.email=''
			lead.customer_remarks=''
			lead.transfer_to_back_office
			lead.generated_on=Time.now
			lead.save

			UserMailer.new_lead_notification(lead).deliver
			
		end

		render :nothing => true		
	
	end

	def microsite_whatsapp_lead_create
		mobile=params[:mobile]
		project=params[:project]

		project_id=BusinessUnit.find_by_name(project).id

		if Lead.find_by(mobile: mobile, business_unit_id: project_id, status: false)!=nil
		UserMailer.api_testing_other(['whatsapp_mobile_duplicate', params, 'Jain Group']).deliver	
		elsif Lead.find_by(mobile: mobile, business_unit_id: project_id, status: nil)!=nil
		UserMailer.api_testing_other(['whatsapp_mobile_duplicate', params, 'Jain Group']).deliver	
		elsif Lead.where(mobile: mobile, business_unit_id: project_id, status: true).where('created_at > ?', Date.today-7.days)!=[]
		UserMailer.api_testing_other(['whatsapp_mobile_duplicate_lost_last_7_days', params, 'Jain Group']).deliver	
		else
			lead=Lead.new
			lead.mobile=params[:mobile]
			lead.business_unit_id=BusinessUnit.find_by_name(project).id
			lead.source_category_id=1060
			lead.name='Landing Page Whatsapp -'+mobile
			lead.email=''
			lead.customer_remarks=''
			lead.transfer_to_back_office
			lead.generated_on=Time.now
			lead.save

			UserMailer.new_lead_notification(lead).deliver
			
		end

		render :nothing => true
	end

	def check_lead_existence
		#accept mobile and organisation
		mobile=params[:mobile]
		# organisation_id=Organisation.find_by_name('Jain Group').id
		lead=Lead.includes(:business_unit).where(:business_units => {organisation_id: 1}, mobile: mobile, lost_reason_id: nil)[0]
		if lead==nil
		render text: 'false'
		else
		render text: lead.business_unit.name+'-'+(lead.id.to_s)+'#'+(lead.personnel.mobile)
		end

		#if yes send back lead_id, business_unit_name
	end

	def mobile_check
		lead=Lead.includes(:business_unit).where(:leads => {mobile: params['mobile']}, :business_units => {organisation_id: 1})
		if lead == []
			render text: 'false'
		else
			flat=Flat.find_by_lead_id(lead[0].id)
			if flat==nil
				bookings=Booking.includes(:cost_sheet => [:lead]).where(:leads => {mobile: params['mobile']})
				if bookings != []
					flat=bookings[0].cost_sheet.flat
				end
			end
			if flat==nil
				render text: 'false'
			elsif flat.chat_id==nil
				render text: 'false'
			else
				render text: flat.chat_id
			end
		end
	end

	def isv_lead
		mobile=params['mobile']
		project=params['project']
		business_unit_id=BusinessUnit.find_by_name(project).try(:id)
		lead=Lead.where(mobile: mobile, business_unit_id: business_unit_id, booked_on: nil)[0]
		if lead != nil
			if lead.qualified_on==nil
				lead.update(interested_in_site_visit_on: Time.now, osv: true, status: false)
				lead.update(qualified_on: Time.now) if lead.qualified_on==nil
				lead.update(reengaged_on: Time.now) if lead.reengaged_on==nil
			last_follow_up=lead.follow_ups.where(last: true)[0]
				follow_up=FollowUp.new
				if last_follow_up==nil
					follow_up.lead_id=lead.id
					follow_up.personnel_id=lead.personnel_id
					follow_up.remarks='qualified through whatsapp'
					follow_up.communication_time=Time.now
					follow_up.follow_up_time=Time.now+15.minutes
					follow_up.status=false
					follow_up.osv=true
					follow_up.first=true
					follow_up.last=true
				else
					follow_up.lead_id=lead.id
					follow_up.personnel_id=lead.personnel_id
					follow_up.remarks='qualified through whatsapp'
					follow_up.communication_time=Time.now
					follow_up.follow_up_time=Time.now+15.minutes
					follow_up.status=false
					follow_up.osv=true
					follow_up.last=true
					follow_up.scheduled_time=last_follow_up.follow_up_time
					last_follow_up.update(last: nil)
				end
				follow_up.save
			end
		end
		render text: 'qualified'
	end

	def qualify_lead
		mobile=params['mobile']
		project=params['project']
		business_unit_id=BusinessUnit.find_by_name(project).try(:id)
		lead=Lead.where(mobile: mobile, business_unit_id: business_unit_id, booked_on: nil)[0]
		if lead != nil
			if lead.qualified_on==nil
				lead.update(qualified_on: Time.now, osv: true, status: false)
				lead.update(reengaged_on: Time.now) if lead.reengaged_on==nil
			last_follow_up=lead.follow_ups.where(last: true)[0]
				follow_up=FollowUp.new
				if last_follow_up==nil
					follow_up.lead_id=lead.id
					follow_up.personnel_id=lead.personnel_id
					follow_up.remarks='qualified through whatsapp'
					follow_up.communication_time=Time.now
					follow_up.follow_up_time=Time.now+15.minutes
					follow_up.status=false
					follow_up.osv=true
					follow_up.first=true
					follow_up.last=true
				else
					follow_up.lead_id=lead.id
					follow_up.personnel_id=lead.personnel_id
					follow_up.remarks='qualified through whatsapp'
					follow_up.communication_time=Time.now
					follow_up.follow_up_time=Time.now+15.minutes
					follow_up.status=false
					follow_up.osv=true
					follow_up.last=true
					follow_up.scheduled_time=last_follow_up.follow_up_time
					last_follow_up.update(last: nil)
				end
				follow_up.save
			end
		end
		render text: 'qualified'
	end

	def lead_reengaged
		mobile=params['mobile']
		project=params['project']
		business_unit_id=BusinessUnit.find_by_name(project).try(:id)
		lead=Lead.where(mobile: mobile, business_unit_id: business_unit_id, booked_on: nil)[0]
		lead.update(reengaged_on: Time.now) if lead != nil
		render text: 'lead reengaged !'
	end

	def mark_lead_hot
		mobile=params['mobile']
		project=params['project']
		business_unit_id=BusinessUnit.find_by_name(project).try(:id)
		lead=Lead.where(mobile: mobile, business_unit_id: business_unit_id, booked_on: nil)[0]
		lead.update(anticipation: 'Hot') if lead != nil
		render text: 'marked hot'
	end
	
	def chat_id_check
		flat=Flat.find_by_chat_id(params['chat_id'])
		if flat==nil
			render text: 'false'
		else
			if flat.lead_id==nil
			bookings=Booking.includes(:cost_sheet).where(:cost_sheets =>{flat_id: flat.id})
				if bookings != []
					render text: '91'+(bookings[0].cost_sheet.lead.mobile)
				else
					render text: 'false'		
				end
			else
			render text: '91'+(flat.lead.mobile)
			end
		end
	end

	def create_whatsapp
		message=params[:message]
		lead_id=params[:lead_id].to_i
		by_lead=params[:by_lead]

		lead_whatsapp=Whatsapp.new
		lead_whatsapp.lead_id=lead_id
		if by_lead=='true'
		lead_whatsapp.by_lead=true
		end
		lead_whatsapp.message=message
		lead_whatsapp.save

		render :nothing => true
		#accept lead_id message and by_lead
	end
	# def websites
	# 	if params[:ToFull][0][:Email]=="marketing@thejaingroup.com"
	# 	@email=Email.new
	# 	@email.subject=params[:Subject]
	# 	@email.from=params[:From]
	# 	@email.body=params[:HtmlBody]		
	# 	@email.date=Time.now
	# 	@email.organisation_id=2
	# 	@email.save
	# 	if @email.from='no-reply@99acres.com'
	# 		@stripped_email=strip_tags(@email.body)	
	# 		@name_index=@stripped_email.index("Name:")
	# 		@number_index=@stripped_email.index("Contact Number:")
	# 		@email_index=@stripped_email.index("Email ID:")
	# 		@query_index=@stripped_email.index("Query:")
	# 		@last_index=@stripped_email.index("Reply by email")
	# 		if @name_index!=nil && @number_index!=nil
	# 		@draft_name=@stripped_email.at((@name_index+6)..(@number_index-1))
	# 		@draft_number=@stripped_email.at((@number_index+16)..(@email_index-1))
	# 		@draft_email=@stripped_email.at((@email_index+10)..(@query_index-1))
	# 		@draft_query=@stripped_email.at((@query_index+6)..(@last_index-1))

	# 		@draft_name_index=@draft_name.index("\r")
	# 		@draft_number_index=@draft_number.index("\r")
	# 		@draft_email_index=@draft_email.index("\r")
	# 		@draft_query_index=@draft_query.index("\r")

	# 		@name=@draft_name.at(0..(@draft_name_index-1))
	# 		@number=@draft_number.at(0..(@draft_number_index-1))
	# 		@email=@draft_email.at(0..(@draft_email_index-1))
	# 		@query=@draft_query.at(0..(@draft_query_index-1))

	# 		@lead=Lead.new
	# 		@lead.name=@name
	# 		@lead.email=@email
	# 		@lead.business_unit_id=BusinessUnit.find_by_name('Dream One')
	# 		@lead.source_category_id=SourceCategory.find_by_description('99 Acres')
	# 		@lead.customer_remarks=@query
	# 		@mobile_index=@number.index("-")
	# 		@number[@mobile_index]=''
	# 		@number='+' + @number
	# 		@lead.mobile=@number
	# 		@lead.save
	# 		@lead_details=[@name, @number, @email, @query, '99 Acres']
	# 		UserMailer.detect_lead(@lead_details).deliver
	# 		end
	# 	end
	# 	end
	# 	render :nothing => true
	# end

	def alcove_chat
		if params[:type] != "error" && params[:message] && params[:message][:text] != nil && params[:phone_id]==20283
		body=params[:message][:text]
		mobile=params[:user][:phone]
		chat_id=params[:conversation]
		message_id=params[:message][:id]
		from_me=params[:message]['fromMe']
		replied_to_message_id=params[:message]['quotedMsgId']
		message=''
		lead_mobile=mobile[2..11]
		
		lead=Lead.includes(:business_unit).where(mobile: lead_mobile, :business_units => {organisation_id: Organisation.find_by_name('Alcove Group').id})[0]
		
		if body.gsub(/\s+/, '').downcase.include?('facebookpost') || body.gsub(/\s+/, '').downcase.include?('newkolkata.in') || body.gsub(/\s+/, '').downcase.include?('newkolkatalandingpage') || body.gsub(/\s+/, '').downcase.include?('alcovenewkolkata') 
					if body.gsub(/\s+/, '').downcase.include?('facebookpost')
					source='Social Media Facebook Orm'
					elsif body.gsub(/\s+/, '').downcase.include?('newkolkata.in')
					source='Website New Kolkata'
					elsif body.gsub(/\s+/, '').downcase.include?('newkolkatalandingpage')
					source='NEW KOLKATA LANDING PAGE'
					elsif body.gsub(/\s+/, '').downcase.include?('alcovenewkolkata')
					source='LP-Flat for sale in Kolkata-Whatsapp'
					end

					require "uri"
					require "json"
					require "net/http"

					url = URI("http://erp.alcoverealty.in/HighriseMarketingServices/enqintegration.svc/RegisterEnquiryData")

					http = Net::HTTP.new(url.host, url.port);
					request = Net::HTTP::Post.new(url)
					request["Content-Type"] = "application/json"
					if source=='LP-Flat for sale in Kolkata-Whatsapp'
					request.body = JSON.dump({"Name" => lead_mobile,"Mobile" => lead_mobile,"Email" => "","Site" => "NEW KOLKATA - SANGAM","Source" => source,"Subsource" => "","TypeOfUnit" => "","Keyword" => "","MatchType" => "","Creative" => "","Placement" => "","Model" => "","CampaignType" => "","UTM_Source" => "","UTM_Medium" => "","GCLID" => "","Remark" => "","Text1" => "","Text2" => "","Text3" => "","Text4" => "","Text5" => "","Portal_ID" => ""}.to_json)
					else
					request.body = JSON.dump({"Name" => (source+"-"+lead_mobile),"Mobile" => lead_mobile,"Email" => "","Site" => "NEW KOLKATA - SANGAM","Source" => source,"Subsource" => "","TypeOfUnit" => "","Keyword" => "","MatchType" => "","Creative" => "","Placement" => "","Model" => "","CampaignType" => "","UTM_Source" => "","UTM_Medium" => "","GCLID" => "","Remark" => "","Text1" => "","Text2" => "","Text3" => "","Text4" => "","Text5" => "","Portal_ID" => ""}.to_json)
					end
					response = http.request(request)

					if source=='LP-Flat for sale in Kolkata-Whatsapp'
					sf_name=lead_mobile
					else
					sf_name=(source+"-"+lead_mobile)
					end
					
					urlstring =  "https://alcoverealty.my.salesforce-sites.com/websitehook/services/apexrest/hookinlandingPage"
					    result = HTTParty.post(urlstring,
					       :body => {
					            "Leads": [
					                        {
					                              "FName": sf_name,
	                    					      "LName": "-whatsapp",
	                    					      "Phone": lead_mobile,
	                    					      "City": "Kolkata",
	                    					      "project": "NEW KOLKATA - SANGAM",
	                    					      "Email": "",
	                    					      "Campaign": "",
	                    					      "Source": "LP-Flat for sale in Kolkata-Whatsapp",
	                    					      "Sub_Source": "LP-Flat for sale in Kolkata-Whatsapp",
	                    					      "Medium": "",
	                    					      "Content": "",
	                    					      "Term": ""
					                        }
					                    ]
					                }.to_json,
					                :headers => {'Content-Type' => 'application/json'} )
									


		end


		if lead != nil
		
			if lead.business_unit.name=='New Kolkata Sangam'
				brochure_url="https://onedrive.live.com/download?resid=55E14145A4D50C02%21662&authkey=!ACA1f1WH16Uvqes&em=2"
				plan_url='https://imageclassify.s3.amazonaws.com/new_kolkata_sangam_plan.pdf'
				photo_url="Please click on the following link to view photo gallery - https://www.newkolkata.in/gallery\n\n"+"Please visit our YouTube page for videos - https://www.youtube.com/channel/UCnpDLu2UNHPlY2gojCgRqkw\n\n"+"Don’t forget to check these out:\n\n"+"Project walkthrough: https://www.youtube.com/watch?v=6GZdHD15bQE\n\n"+"Architect Hafeez Contractor on New Kolkata (Episode 1): https://www.youtube.com/watch?v=SEmi9q1rjak\n\n"+"Architect Hafeez Contractor on New Kolkata (Episode 2): https://www.youtube.com/watch?v=ZXurbGvDKxA\n\n"+"Mamata Shankar on New Kolkata - https://www.youtube.com/watch?v=GDLjFZiFgJc\n\n"+"Ganga Aarti - https://www.youtube.com/watch?v=jp67Ml4UbFc"
				# photo_url='https://www.newkolkata.in/gallery'
				location_link='https://goo.gl/maps/QhMce3sY3RYZRrV18'
				address="449/A/2, Grand Trunk Rd, Mahesh, Mahesh Bose Para, Serampore, West Bengal 712202"
				location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8335057755"
				walkthrough_url='https://youtu.be/i5RmrBHD_hE'
			elsif lead.business_unit.name=='New Kolkata Prayag' || lead.business_unit.name=='NEW KOLKATA - PRAYAG' 
				brochure_url='https://onedrive.live.com/download?resid=55E14145A4D50C02%21662&authkey=!ACA1f1WH16Uvqes&em=2'
				plan_url='https://imageclassify.s3.amazonaws.com/new_kolkata_prayag_plan.pdf'
				photo_url="Please click on the following link to view photo gallery - https://www.newkolkata.in/gallery\n\n"+"Please visit our YouTube page for videos - https://www.youtube.com/channel/UCnpDLu2UNHPlY2gojCgRqkw\n\n"+"Don’t forget to check these out:\n\n"+"Project walkthrough: https://www.youtube.com/watch?v=6GZdHD15bQE\n\n"+"Architect Hafeez Contractor on New Kolkata (Episode 1): https://www.youtube.com/watch?v=SEmi9q1rjak\n\n"+"Architect Hafeez Contractor on New Kolkata (Episode 2): https://www.youtube.com/watch?v=ZXurbGvDKxA\n\n"+"Mamata Shankar on New Kolkata - https://www.youtube.com/watch?v=GDLjFZiFgJc\n\n"+"Ganga Aarti - https://www.youtube.com/watch?v=jp67Ml4UbFc"
				# photo_url='https://www.newkolkata.in/gallery'
				location_link='https://goo.gl/maps/QhMce3sY3RYZRrV18'
				address="449/A/2, Grand Trunk Rd, Mahesh, Mahesh Bose Para, Serampore, West Bengal 712202"
				location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8335057755"
				walkthrough_url='https://youtu.be/i5RmrBHD_hE'
			elsif BusinessUnit.find_by_name('The 42')
				brochure_url='https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21519&authkey=AFk-Cz9poJZ2Krw&em=2'
				plan_url='https://imageclassify.s3.amazonaws.com/NEW+KOLKATA+SANGAM+-+PLAN.pdf'
				photo_url='https://www.newkolkata.in/gallery'
				location_link='https://goo.gl/maps/QhMce3sY3RYZRrV18'
				address="449/A/2, Grand Trunk Rd, Mahesh, Mahesh Bose Para, Serampore, West Bengal 712202"
				location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8335057755"
				walkthrough_url='https://www.youtube.com/watch?v=TtwhX-P1L04'
			elsif BusinessUnit.find_by_name('Flora Fountain')
				brochure_url='https://imageclassify.s3.amazonaws.com/flora_fountain_brochure.pdf'
				plan_url='https://imageclassify.s3.amazonaws.com/NEW+KOLKATA+SANGAM+-+PLAN.pdf'
				photo_url='https://www.newkolkata.in/gallery'
				location_link='https://goo.gl/maps/QhMce3sY3RYZRrV18'
				address="449/A/2, Grand Trunk Rd, Mahesh, Mahesh Bose Para, Serampore, West Bengal 712202"
				location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8335057755"
				walkthrough_url='https://www.youtube.com/watch?v=TtwhX-P1L04'
			elsif BusinessUnit.find_by_name('Alcove Towers')
				brochure_url='https://imageclassify.s3.amazonaws.com/alcove_tower_brochure.pdf'
				plan_url='https://imageclassify.s3.amazonaws.com/NEW+KOLKATA+SANGAM+-+PLAN.pdf'
				photo_url='https://www.newkolkata.in/gallery'
				location_link='https://goo.gl/maps/QhMce3sY3RYZRrV18'
				address="449/A/2, Grand Trunk Rd, Mahesh, Mahesh Bose Para, Serampore, West Bengal 712202"
				location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8335057755"
				walkthrough_url='https://www.youtube.com/watch?v=TtwhX-P1L04'
			elsif BusinessUnit.find_by_name('Alcove Regency')
				brochure_url='https://imageclassify.s3.amazonaws.com/alcove_regency_brochure.pdf'
				plan_url='https://imageclassify.s3.amazonaws.com/NEW+KOLKATA+SANGAM+-+PLAN.pdf'
				photo_url='https://www.newkolkata.in/gallery'
				location_link='https://goo.gl/maps/QhMce3sY3RYZRrV18'
				address="449/A/2, Grand Trunk Rd, Mahesh, Mahesh Bose Para, Serampore, West Bengal 712202"
				location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8335057755"
				walkthrough_url='https://www.youtube.com/watch?v=TtwhX-P1L04'
			else
				brochure_url='https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21519&authkey=AFk-Cz9poJZ2Krw&em=2'	
				plan_url='https://imageclassify.s3.amazonaws.com/new_kolkata_sangam_plan.pdf'
				photo_url='https://www.newkolkata.in/gallery'
				location_link='https://goo.gl/maps/QhMce3sY3RYZRrV18'
				address="449/A/2, Grand Trunk Rd, Mahesh, Mahesh Bose Para, Serampore, West Bengal 712202"
				location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8335057755"
				walkthrough_url='https://www.youtube.com/watch?v=TtwhX-P1L04'
			end
				
			if from_me != true
				if body.gsub(/\s+/, '').downcase=='hi'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
				elsif body.gsub(/\s+/, '').downcase=='hello'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
				elsif body.gsub(/\s+/, '').downcase=='hii'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
				elsif body.gsub(/\s+/, '').downcase=='hey'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
				elsif body.gsub(/\s+/, '').downcase=='hye'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
				elsif body.gsub(/\s+/, '').downcase.include? 'morn'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
				elsif body.gsub(/\s+/, '').downcase.include? 'noon'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
				elsif body.gsub(/\s+/, '').downcase.include? 'thank'
					message="You are most welcome🙏\n\nRegards,\nAlcove Realty\n9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'thx'
					message="You are most welcome🙏\n\nRegards,\nAlcove Realty\n9555-700-222"
				elsif body.gsub(/\s+/, '').downcase=='okay' || body.gsub(/\s+/, '').downcase=='ok' || body.gsub(/\s+/, '').downcase=='ohk' || body.gsub(/\s+/, '').downcase=='k' || body.gsub(/\s+/, '').downcase=='okk'
					message="Thank you for your valuable time🙏\n\nRegards,\nAlcove Realty\n9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'notinterested'
					message="Thank you for your valuable time🙏\n\nRegards,\nAlcove Realty"
				elsif body.gsub(/\s+/, '').downcase=="👍" || body.gsub(/\s+/, '').downcase=="👍🏽" || body.gsub(/\s+/, '').downcase=="👍🏻" || body.gsub(/\s+/, '').downcase=="nice" ||  body.gsub(/\s+/, '').downcase=="cool" || body.gsub(/\s+/, '').downcase=="vow" || body.gsub(/\s+/, '').downcase=="welcome" || body.gsub(/\s+/, '').downcase=="wlcm"
					message='Anytime 😎'
				elsif body.gsub(/\s+/, '').downcase=='yes'
					message="ok"
				end

									
				if body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?(':')
				  	message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nAlcove Realty\n9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('-')
					message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nAlcove Realty\n9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('am')
					message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nAlcove Realty\n9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('pm')
					message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nAlcove Realty\n9555-700-222"
				else
				  
				  #multiple selections seperated by comma or and

				  number_series=body.downcase.gsub(/\s+/, '').gsub(',', '').gsub(';', '').gsub(')', '').gsub('and', '').gsub('&', '').gsub('.', '').gsub('nos', '').gsub('no', '').gsub('sl', '').gsub('/', '').gsub('send', '').gsub('n', '').gsub('to', '').gsub('-', '')

				  if number_series.length>1
				  	if number_series[0].to_i != 0 || number_series.reverse[0].to_i != 0
				  		number_length=number_series.length
				  		if number_series.reverse[0].to_i != 0 && number_series[0].to_i == 0
				  			number_series=number_series.reverse
				  		end
				  		number_length.times do |position|
				  			if number_series[position].to_i == 0
				  				message=''
				  				break
				  			elsif number_series[position]=='1'
  								message='👇 Brochure being sent please wait...'

							    urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

  								# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
  				    #             result = HTTParty.get(urlstring,
  				    #                     :body => { :phone => mobile,
  				    #                               :body => brochure_url,
  				    #                               :filename => 'brochure.pdf'  
  				    #                               }.to_json,
  				    #                    :headers => { 'Content-Type' => 'application/json' } )

  								
  							elsif number_series[position]=='2'
  								message='👇 Floor Plans being sent please wait...'
  								
							    urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => plan_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


  								# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
  				    #             result = HTTParty.get(urlstring,
  				    #                     :body => { :phone => mobile,
  				    #                               :body => plan_url,
  				    #                               :filename => 'floor plans.pdf'  
  				    #                               }.to_json,
  				    #                    :headers => { 'Content-Type' => 'application/json' } )	
  							elsif number_series[position]=='3'
  								
							    urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => location_link,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


  								# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
  				    #             result = HTTParty.get(urlstring,
  				    #                     :body => { :phone => mobile,
  				    #                               :body => location_link,
  				    #                               :title => 'Alcove New Kolkata',
  				    #                               :description => address  
  				    #                               }.to_json,
  				    #                    :headers => { 'Content-Type' => 'application/json' } )
  				                message=location_text
  							elsif number_series[position]=='4'
  								message=photo_url
  							elsif number_series[position]=='5'
  								message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
  								UserMailer.whatsapp_site_visit([mobile, lead.id]).deliver			
  							elsif number_series[position]=='6'
  								message='Please click on the following link to view our Company Profile - https://www.alcoverealty.in/company-profile'			
  							elsif number_series[position]=='7'
  								# 76050-33667
  								message='Kindly click: https://wa.me/917596049697'
  							elsif number_series[position]=='8'
  								message=walkthrough_url		
  							end

				  			if position < (number_length-1)

  						    urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
  						  		result = HTTParty.post(urlstring,
  								   :body => { :to_number => mobile,
  			                		 :message => message,	
  			                          :type => "text"
  			                          }.to_json,
  			                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            
	

				  			# urlstring =  "https://eu71.chat-api.com/instance139798/sendMessage?token=39ej4g9g8bxuuona"
				  			# 	  		result = HTTParty.get(urlstring,
				  			# 			   :body => { :phone => mobile,
				  			# 			              :body => message 
				  			# 			              }.to_json,
				  						   # :headers => { 'Content-Type' => 'application/json' } )
				  			end
				  		end
				  	end
				  end
				end	

				if body.gsub(/\s+/, '')=='1'
					message='👇 Brochure being sent please wait...'

				    urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
				  		result = HTTParty.post(urlstring,
						   :body => { :to_number => mobile,
	                		 :message => brochure_url,	
	                          :text => "",
	                          :type => "media"
	                          }.to_json,
	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => brochure_url,
	    #                               :filename => 'brochure.pdf'  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )

					
				elsif body.gsub(/\s+/, '')=='2'
					message='👇 Floor Plans being sent please wait...'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => plan_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => plan_url,
	    #                               :filename => 'floor plans.pdf'  
	    #                               }.to_json,
	                       # :headers => { 'Content-Type' => 'application/json' } )	
				elsif body.gsub(/\s+/, '')=='3'
		
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => location_link,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	                       # :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
				elsif body.gsub(/\s+/, '')=='4'
					message=photo_url
				elsif body.gsub(/\s+/, '')=='5'
					message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
					UserMailer.whatsapp_site_visit([mobile, lead.id]).deliver
				elsif body.gsub(/\s+/, '')=='6'
					message='Please click on the following link to view our Company Profile - https://www.alcoverealty.in/company-profile'			
				elsif body.gsub(/\s+/, '')=='7'
					message='Kindly click: https://wa.me/917596049697'
				elsif body.gsub(/\s+/, '')=='8'
					message=walkthrough_url		
				end

				if body.gsub(/\s+/, '').downcase.include? 'brochur'
					message='👇 Brochure being sent please wait...'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => brochure_url,
	    #                               :filename => 'brochure.pdf'  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )

				elsif body.gsub(/\s+/, '').downcase.include? 'projectdetail'
					message='👇 Brochure being sent please wait...'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => brochure_url,
	    #                               :filename => 'brochure.pdf'  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )

	            elsif body.gsub(/\s+/, '').downcase.include? 'plan'
					message='👇 Floor Plans being sent please wait...'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => plan_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => plan_url,
	    #                               :filename => 'floor plans.pdf'  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )

	            elsif body.gsub(/\s+/, '').downcase.include? 'facilit'
					message='👇 Brochure being sent please wait...'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => brochure_url,
	    #                               :filename => 'brochure.pdf'  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )

				elsif body.gsub(/\s+/, '').downcase.include? 'specific'
					message='👇 Brochure being sent please wait...'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => brochure_url,
	    #                               :filename => 'brochure.pdf'  
	    #                               }.to_json,
	                       # :headers => { 'Content-Type' => 'application/json' } )			
				elsif body.gsub(/\s+/, '').downcase.include? 'locat'
					
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => mobile,
					                		 :message => location_link,	
					                          :type => "text"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
				elsif body.gsub(/\s+/, '').downcase.include? 'map'
					
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => location_link,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
				elsif body.gsub(/\s+/, '').downcase.include? 'address'
					
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => location_link,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'beyond'
					
	            		urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'beside'
					
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'near'
					
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'where'
					
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'north'
					
				urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'south'
					
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'west'
					
	            	urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'east'
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            
					
					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text
	            elsif body.gsub(/\s+/, '').downcase.include? 'around'
	
	            	urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => location_link,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendLink?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => location_link,
	    #                               :title => 'Alcove New Kolkata',
	    #                               :description => address  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                message=location_text                                    
	            elsif body.gsub(/\s+/, '').downcase.include? 'gallery'
					message=photo_url
				elsif body.gsub(/\s+/, '').downcase.include? 'video'
					message=photo_url
				elsif body.gsub(/\s+/, '').downcase.include? 'photo'
					message=photo_url
				elsif body.gsub(/\s+/, '').downcase.include? 'pic'
					message=photo_url
				elsif body.gsub(/\s+/, '').downcase.include? 'payment'
					message="For payment related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'emi'
					message="For EMI related assistance kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'availabl'
					message="For availability related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'loan'
					message="For loan related assistance kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'bank'
					message="For loan related assistance kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'rate'
					message="For rate/sft related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'posess'
					message="For possession/completion related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'possess'
					message="For possession/completion related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'complet'
					message="For possession/completion related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'handover'
					message="For possession/completion related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'delivery'
					message="For possession/completion related queries kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'bhk'
					message="For queries related to price of flat, kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'cost'
					message="For queries related to price of flat, kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'price'
					message="For queries related to price of flat, kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'budget'
					message="For queries related to price of flat, kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'totalarea'
					message="For land area, kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'landarea'
					message="For land area, kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'areaofland'
					message="For land area, kindly click https://wa.me/91"+"7596049697"+" to chat with our executive.\n\nOr call us @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'book'
					message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
				elsif body.gsub(/\s+/, '').downcase.include? 'visit'
					message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"	
				elsif body.gsub(/\s+/, '').downcase.include? 'appoint'
					message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"	
				elsif body.gsub(/\s+/, '').downcase.include? 'chat'
					message='Kindly click: https://wa.me/917596049697'
				elsif body.gsub(/\s+/, '').downcase.include? 'expert'
					message='Kindly click: https://wa.me/917596049697'
				elsif body.gsub(/\s+/, '').downcase.include? 'human'
					message='Kindly click: https://wa.me/917596049697'	
				elsif body.gsub(/\s+/, '').downcase.include? 'person'
					message='Kindly click: https://wa.me/917596049697'	
				elsif body.gsub(/\s+/, '').downcase.include? 'executive'
					message='Kindly click: https://wa.me/917596049697'	
				elsif body.gsub(/\s+/, '').downcase.include? 'someone'
					message='Kindly click: https://wa.me/917596049697'	
				elsif body.gsub(/\s+/, '').downcase.include? 'somebody'
					message='Kindly click: https://wa.me/917596049697'	
				elsif body.gsub(/\s+/, '').downcase.include? 'about'
					message='https://www.alcoverealty.in/company-profile'
				elsif body.gsub(/\s+/, '').downcase.include? 'company'
					message='https://www.alcoverealty.in/company-profile'
				elsif body.gsub(/\s+/, '').downcase.include? 'builder'
					message='https://www.alcoverealty.in/company-profile'
				elsif body.gsub(/\s+/, '').downcase.include? 'profile'
					message='https://www.alcoverealty.in/company-profile'
				elsif body.gsub(/\s+/, '').downcase.include? 'walkthrough'
					message=walkthrough_url
				elsif body.gsub(/\s+/, '').downcase.include? 'call'
					message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+"7596049697"+"\n\nOr you can initiate a call @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'talk'
					message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+"7596049697"+"\n\nOr you can initiate a call @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'help'
					message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+"7596049697"+"\n\nOr you can initiate a call @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'assist'
					message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+"7596049697"+"\n\nOr you can initiate a call @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'contactme'
					message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+"7596049697"+"\n\nOr you can initiate a call @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'getintouch'
					message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+"7596049697"+"\n\nOr you can initiate a call @ "+"9555-700-222"
				elsif body.gsub(/\s+/, '').downcase.include? 'detail'
					message='👇 Brochure being sent please wait...'

					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => brochure_url,	
	            	                          :text => "",
	            	                          :type => "media"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendFile?token=39ej4g9g8bxuuona"
	    #             result = HTTParty.get(urlstring,
	    #                     :body => { :phone => mobile,
	    #                               :body => brochure_url,
	    #                               :filename => 'brochure.pdf'  
	    #                               }.to_json,
	    #                    :headers => { 'Content-Type' => 'application/json' } )
	                           
				end

				

				lead_whatsapp=Whatsapp.new
				lead_whatsapp.lead_id=lead.id
				lead_whatsapp.by_lead=true
				lead_whatsapp.message=body
				lead_whatsapp.save

				alcove_whatsapp=Whatsapp.new
				alcove_whatsapp.lead_id=lead.id
				
				if message != ''
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => message,	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

				# urlstring =  "https://eu71.chat-api.com/instance139798/sendMessage?token=39ej4g9g8bxuuona"
				# 	  		result = HTTParty.get(urlstring,
				# 			   :body => { :phone => mobile,
				# 			              :body => message 
				# 			              }.to_json,
				# 			   :headers => { 'Content-Type' => 'application/json' } )
				alcove_whatsapp.message=message
				else
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/sendMessage"
	            				  		result = HTTParty.post(urlstring,
	            						   :body => { :to_number => mobile,
	            	                		 :message => "Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/917605081410 to chat with our executive.\n\nOr call us @ 9555-700-222\n\nThanks & Regards,\nAlcove Realty",	
	            	                          :type => "text"
	            	                          }.to_json,
	            	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            


					# urlstring =  "https://eu71.chat-api.com/instance139798/sendMessage?token=39ej4g9g8bxuuona"
					#   		result = HTTParty.get(urlstring,
					# 		   :body => { :phone => mobile,
					# 		              :body => "Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/917605081410 to chat with our executive.\n\nOr call us @ 9555-700-222\n\nThanks & Regards,\nAlcove Realty" 
					# 		              }.to_json,
					# 		   :headers => { 'Content-Type' => 'application/json' } )
				alcove_whatsapp.message="Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/917605081410 to chat with our executive.\n\nOr call us @ 9555-700-222\n\nThanks & Regards,\nAlcove Realty"
				end
				alcove_whatsapp.save
				
			end

		else
			if body.gsub(/\s+/, '').downcase=='hi'
					message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
			elsif body.gsub(/\s+/, '').downcase=='hello'
				message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
			elsif body.gsub(/\s+/, '').downcase=='hii'
				message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
			elsif body.gsub(/\s+/, '').downcase=='hey'
				message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
			elsif body.gsub(/\s+/, '').downcase=='hye'
				message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
			elsif body.gsub(/\s+/, '').downcase.include? 'morn'
				message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
			elsif body.gsub(/\s+/, '').downcase.include? 'noon'
				message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
			end
		end	
		
	else
		# bulk_recipient=BulkRecipient.find_by(message_id: params[:ack][0]["id"])
		# if bulk_recipient==nil
		# else
		# 	if params[:ack][0]["status"]=='delivered'
		# 		bulk_recipient.update(delivered: true)
		# 	elsif params[:ack][0]["status"]=='sent'
		# 		bulk_recipient.update(sent: true)
		# 	elsif params[:ack][0]["status"]=='viewed'
		# 		bulk_recipient.update(read: true)
		# 	end
		# end
	end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

		def jsb_chat
			body=params[:messages][0][:body]
			mobile=params[:messages][0]['chatId'][0..11]
			chat_id=params[:messages][0]['chatId']
			message_id=params[:messages][0]['id']
			from_me=params[:messages][0]['fromMe']
			replied_to_message_id=params[:messages][0]['quotedMsgId']
			message=''
			lead_mobile=mobile[2..11]
			
			lead=Lead.includes(:business_unit).where(mobile: lead_mobile, :business_units => {organisation_id: Organisation.find_by_name('JSB Infrastructures').id})[0]
			
			if lead != nil
				if lead.business_unit.name=='JSB Serene Tower'
					brochure_url='https://drive.google.com/uc?id=1Z_3C7njNoohKqa7k0lIT4h8JC3C4ycFd&export=download'
					plan_url='https://drive.google.com/uc?id=1Z_3C7njNoohKqa7k0lIT4h8JC3C4ycFd&export=download'
					photo_url='https://www.jsbinfrastructures.com/serene.php#lg=1&slide=0'
					photo_url_2='https://www.jsbinfrastructures.com/serene.php#lg=3&slide=0'
					location_map='https://drive.google.com/uc?id=1qUkXaHpQ-2Y0f6nkvrVYoGMQh4Eqf8Yg&export=download'
					location_title='JSB Serene Tower'
					location_link='https://goo.gl/maps/HmFTYGyqLtHMTsHo9'
					address="Mohanaghat Road, Amolapatty, Dibgrugarh, Assam"
					location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8099765984"
					ongoing_rate="For queries related to price of flat, kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
				elsif lead.business_unit.name=='JSB Jyoti Residency' 
					brochure_url='https://drive.google.com/uc?id=19_ZJAtyirmEysqXmAU2amFvUS3lc82We&export=download'
					plan_url='https://drive.google.com/uc?id=19_ZJAtyirmEysqXmAU2amFvUS3lc82We&export=download'
					photo_url='https://www.jsbinfrastructures.com/jyoti-residency.php#lg=1&slide=0'
					photo_url_2='https://www.jsbinfrastructures.com/jyoti-residency.php#lg=3&slide=0'
					location_map='https://drive.google.com/uc?id=1ByzftpNBh6Ve8N8LUkyTUYnbJ0EV1Uko&export=download'
					location_link='https://goo.gl/maps/wzgN9RtJVp3ceZgc8'
					location_title='JSB Jyoti Residency'
					address="Dowerah Chuck, Near Dowerah Chuck Field, Dibrugarh, Assam - 786001"
					location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8099765984"
					ongoing_rate="For queries related to price of flat, kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
				else
					brochure_url='https://drive.google.com/uc?id=1Z_3C7njNoohKqa7k0lIT4h8JC3C4ycFd&export=download'
					plan_url='https://drive.google.com/uc?id=1Z_3C7njNoohKqa7k0lIT4h8JC3C4ycFd&export=download'
					photo_url='https://www.jsbinfrastructures.com/serene.php#lg=1&slide=0'
					photo_url_2='https://www.jsbinfrastructures.com/serene.php#lg=3&slide=0'
					location_map='https://drive.google.com/uc?id=1qUkXaHpQ-2Y0f6nkvrVYoGMQh4Eqf8Yg&export=download'
					location_link='https://goo.gl/maps/HmFTYGyqLtHMTsHo9'
					location_title='JSB Serene Tower'
					address="Mohanaghat Road, Amolapatty, Dibgrugarh, Assam"
					location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 8099765984"
					ongoing_rate="For queries related to price of flat, kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
				end
					
				if from_me != true
					if body.gsub(/\s+/, '').downcase=='hi'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hello'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hii'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hey'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hye'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase.include? 'morn'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase.include? 'noon'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase.include? 'thank'
						message="You are most welcome🙏\n\nRegards,\nJSB Infrastructures\n8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'thx'
						message="You are most welcome🙏\n\nRegards,\nJSB Infrastructures\n8099765984"
					elsif body.gsub(/\s+/, '').downcase=='okay' || body.gsub(/\s+/, '').downcase=='ok' || body.gsub(/\s+/, '').downcase=='ohk' || body.gsub(/\s+/, '').downcase=='k' || body.gsub(/\s+/, '').downcase=='okk'
						message="Thank you for your valuable time🙏\n\nRegards,\nJSB Infrastructures\n8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'notinterested'
						message="Thank you for your valuable time🙏\n\nRegards,\nJSB Infrastructures"
					elsif body.gsub(/\s+/, '').downcase=="👍" || body.gsub(/\s+/, '').downcase=="👍🏽" || body.gsub(/\s+/, '').downcase=="👍🏻" || body.gsub(/\s+/, '').downcase=="nice" ||  body.gsub(/\s+/, '').downcase=="cool" || body.gsub(/\s+/, '').downcase=="vow" || body.gsub(/\s+/, '').downcase=="welcome" || body.gsub(/\s+/, '').downcase=="wlcm"
						message='Anytime 😎'
					elsif body.gsub(/\s+/, '').downcase=='yes'
						message="ok"
					end

										
					if body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?(':')
					  	message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJSB Infrastructures\n8099765984"
					elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('-')
						message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJSB Infrastructures\n8099765984"
					elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('am')
						message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJSB Infrastructures\n8099765984"
					elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('pm')
						message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJSB Infrastructures\n8099765984"
					else
					  
					  #multiple selections seperated by comma or and

					  number_series=body.downcase.gsub(/\s+/, '').gsub(',', '').gsub(';', '').gsub(')', '').gsub('and', '').gsub('&', '').gsub('.', '').gsub('nos', '').gsub('no', '').gsub('sl', '').gsub('/', '').gsub('send', '').gsub('n', '').gsub('to', '').gsub('-', '')

					  if number_series.length>1
					  	if number_series[0].to_i != 0 || number_series.reverse[0].to_i != 0
					  		number_length=number_series.length
					  		if number_series.reverse[0].to_i != 0 && number_series[0].to_i == 0
					  			number_series=number_series.reverse
					  		end
					  		number_length.times do |position|
					  			if number_series[position].to_i == 0
					  				message=''
					  				break
					  			elsif number_series[position]=='1'
	  								message='👇 Brochure being sent please wait...'
	  								urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
	  				                result = HTTParty.get(urlstring,
	  				                        :body => { :phone => mobile,
	  				                                  :body => brochure_url,
	  				                                  :filename => 'brochure.pdf'  
	  				                                  }.to_json,
	  				                       :headers => { 'Content-Type' => 'application/json' } )
	  				            elsif number_series[position]=='2'	
	  								urlstring =  "https://eu71.chat-api.com/instance187812/sendLink?token=r88dlb58pg4tjvg7"
	  				                result = HTTParty.get(urlstring,
	  				                        :body => { :phone => mobile,
	  				                                  :body => location_link,
	  				                                  :title => location_title,
	  				                                  :description => address  
	  				                                  }.to_json,
	  				                       :headers => { 'Content-Type' => 'application/json' } )
	  				                message=location_text
	                				urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
	                                result = HTTParty.get(urlstring,
	                                        :body => { :phone => mobile,
	                                                  :body => location_map,
	                                                  :filename => 'map.jpeg'  
	                                                  }.to_json,
	                                       :headers => { 'Content-Type' => 'application/json' } )
	  							elsif number_series[position]=='3'
	  								message=photo_url+"\n\n"+photo_url_2
	  							elsif number_series[position]=='4'
	  								message='31st December 2023'	
	  							elsif number_series[position]=='5'
	  								message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
	  							elsif number_series[position]=='6'
	  								message='https://www.jsbinfrastructures.com/about-us.php'			
	  							elsif number_series[position]=='7'
	  								message='Kindly click: https://wa.me/918099765984?text=ExpertChat'
	  							end

					  			if position < (number_length-1)
					  			urlstring =  "https://eu71.chat-api.com/instance187812/sendMessage?token=r88dlb58pg4tjvg7"
					  				  		result = HTTParty.get(urlstring,
					  						   :body => { :phone => mobile,
					  						              :body => message 
					  						              }.to_json,
					  						   :headers => { 'Content-Type' => 'application/json' } )
					  			end
					  		end
					  	end
					  end
					end	

					if body.gsub(/\s+/, '')=='1'
						message='👇 Brochure being sent please wait...'

						urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
		                result = HTTParty.get(urlstring,
		                        :body => { :phone => mobile,
		                                  :body => brochure_url,
		                                  :filename => 'brochure.pdf'  
		                                  }.to_json,
		                       :headers => { 'Content-Type' => 'application/json' } )

						
					elsif body.gsub(/\s+/, '')=='2'
						urlstring =  "https://eu71.chat-api.com/instance187812/sendLink?token=r88dlb58pg4tjvg7"
		                result = HTTParty.get(urlstring,
		                        :body => { :phone => mobile,
		                                  :body => location_link,
		                                  :title => location_title,
		                                  :description => address  
		                                  }.to_json,
		                       :headers => { 'Content-Type' => 'application/json' } )
		                message=location_text
    					urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
                    	result = HTTParty.get(urlstring,
                            :body => { :phone => mobile,
                                      :body => location_map,
                                      :filename => 'map.jpeg'  
                                      }.to_json,
                           :headers => { 'Content-Type' => 'application/json' } )	
					elsif body.gsub(/\s+/, '')=='3'
						message=photo_url+"\n\n"+photo_url_2
					elsif body.gsub(/\s+/, '')=='4'
						message='31st December 2023'	
					elsif body.gsub(/\s+/, '')=='5'
						message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
					elsif body.gsub(/\s+/, '')=='6'
						message='https://www.jsbinfrastructures.com/about-us.php'			
					elsif body.gsub(/\s+/, '')=='7'
						message='Kindly click: https://wa.me/918099765984?text=ExpertChat'
					end

					if body.gsub(/\s+/, '').downcase.include?('brochur') || 
						body.gsub(/\s+/, '').downcase.include?('facilit') || 
						body.gsub(/\s+/, '').downcase.include?('specific') || 
						body.gsub(/\s+/, '').downcase.include?('ameni')
						message='👇 Brochure being sent please wait...'
						urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
		                result = HTTParty.get(urlstring,
		                        :body => { :phone => mobile,
		                                  :body => brochure_url,
		                                  :filename => 'brochure.pdf'  
		                                  }.to_json,
		                       :headers => { 'Content-Type' => 'application/json' } )
					elsif body.gsub(/\s+/, '').downcase.include? 'projectdetail'
						message='👇 Brochure being sent please wait...'
						urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
		                result = HTTParty.get(urlstring,
		                        :body => { :phone => mobile,
		                                  :body => brochure_url,
		                                  :filename => 'brochure.pdf'  
		                                  }.to_json,
		                       :headers => { 'Content-Type' => 'application/json' } )
		            elsif body.gsub(/\s+/, '').downcase.include? 'plan'
						message='👇 Floor Plans being sent please wait...'
						urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
		                result = HTTParty.get(urlstring,
		                        :body => { :phone => mobile,
		                                  :body => plan_url,
		                                  :filename => 'floor plans.pdf'  
		                                  }.to_json,
		                       :headers => { 'Content-Type' => 'application/json' } )
		            elsif body.gsub(/\s+/, '').downcase.include?('locat') || 
		            	body.gsub(/\s+/, '').downcase.include?('map') || 
		            	body.gsub(/\s+/, '').downcase.include?('address') || 
		            	body.gsub(/\s+/, '').downcase.include?('beyond') || 
		            	body.gsub(/\s+/, '').downcase.include?('beside') || 
		            	body.gsub(/\s+/, '').downcase.include?('near') || 
		            	body.gsub(/\s+/, '').downcase.include?('where') || 
		            	body.gsub(/\s+/, '').downcase.include?('north') || 
		            	body.gsub(/\s+/, '').downcase.include?('south') || 
		            	body.gsub(/\s+/, '').downcase.include?('west') || 
		            	body.gsub(/\s+/, '').downcase.include?('east') || 
		            	body.gsub(/\s+/, '').downcase.include?('around')
						urlstring =  "https://eu71.chat-api.com/instance187812/sendLink?token=r88dlb58pg4tjvg7"
		                result = HTTParty.get(urlstring,
		                        :body => { :phone => mobile,
		                                  :body => location_link,
		                                  :title => location_title,
		                                  :description => address  
		                                  }.to_json,
		                       :headers => { 'Content-Type' => 'application/json' } )
		                message=location_text
    					urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
                    	result = HTTParty.get(urlstring,
                            :body => { :phone => mobile,
                                      :body => location_map,
                                      :filename => 'map.jpeg'  
                                      }.to_json,
                           :headers => { 'Content-Type' => 'application/json' } )
					elsif body.gsub(/\s+/, '').downcase.include?('gallery') || 
						body.gsub(/\s+/, '').downcase.include?('video') || 
						body.gsub(/\s+/, '').downcase.include?('photo') || 
						body.gsub(/\s+/, '').downcase.include?('pic')		
   						message=+"\n\n"+photo_url_2
					elsif body.gsub(/\s+/, '').downcase.include? 'payment'
						message="For payment related queries kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'emi'
						message="For EMI related assistance kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'availabl'
						message="For availability related queries kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'loan'
						message="For loan related assistance kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'bank'
						message="For loan related assistance kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'rate'
						message=ongoing_rate
					elsif body.gsub(/\s+/, '').downcase.include?('posess') || 
						body.gsub(/\s+/, '').downcase.include?('possess') || 
						body.gsub(/\s+/, '').downcase.include?('complet') || 
						body.gsub(/\s+/, '').downcase.include?('handover') || 
						body.gsub(/\s+/, '').downcase.include?('deliver') 
						message='31st December 2023'
					elsif body.gsub(/\s+/, '').downcase.include?('bhk') || 
						body.gsub(/\s+/, '').downcase.include?('cost') || 
						body.gsub(/\s+/, '').downcase.include?('price') || 
						body.gsub(/\s+/, '').downcase.include?('budget') 	
						message="For queries related to price of flat, kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include?('totalarea') || 
						body.gsub(/\s+/, '').downcase.include?('landarea') || 
						body.gsub(/\s+/, '').downcase.include?('areaofland')
						message="For land area, kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include?('book') || 
						body.gsub(/\s+/, '').downcase.include?('visit') || 
						body.gsub(/\s+/, '').downcase.include?('appoint')	
						message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
					elsif body.gsub(/\s+/, '').downcase.include?('chat') || 
						body.gsub(/\s+/, '').downcase.include?('expert') || 
						body.gsub(/\s+/, '').downcase.include?('human') || 
						body.gsub(/\s+/, '').downcase.include?('person') || 
						body.gsub(/\s+/, '').downcase.include?('executive') || 
						body.gsub(/\s+/, '').downcase.include?('someone') || 
						body.gsub(/\s+/, '').downcase.include?('somebody') 
						message='Kindly click: https://wa.me/918099765984?text=ExpertChat'
					elsif body.gsub(/\s+/, '').downcase.include?('about') || 
						body.gsub(/\s+/, '').downcase.include?('company') || 
						body.gsub(/\s+/, '').downcase.include?('builder') || 
						body.gsub(/\s+/, '').downcase.include?('profile')
						message='https://www.jsbinfrastructures.com/about-us.php'
					elsif body.gsub(/\s+/, '').downcase.include?('call') || 
						body.gsub(/\s+/, '').downcase.include?('talk') || 
						body.gsub(/\s+/, '').downcase.include?('help') || 
						body.gsub(/\s+/, '').downcase.include?('assist') || 
						body.gsub(/\s+/, '').downcase.include?('contactme') || 
						body.gsub(/\s+/, '').downcase.include?('getintouch')
						message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+"8099765984?text=ExpertChat"+"\n\nOr you can initiate a call @ "+"8099765984"
					elsif body.gsub(/\s+/, '').downcase.include? 'detail'
						message='👇 Brochure being sent please wait...'
						urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
		                result = HTTParty.get(urlstring,
		                        :body => { :phone => mobile,
		                                  :body => brochure_url,
		                                  :filename => 'brochure.pdf'  
		                                  }.to_json,
		                       :headers => { 'Content-Type' => 'application/json' } )
					end

					

					lead_whatsapp=Whatsapp.new
					lead_whatsapp.lead_id=lead.id
					lead_whatsapp.by_lead=true
					lead_whatsapp.message=body
					lead_whatsapp.save

					alcove_whatsapp=Whatsapp.new
					alcove_whatsapp.lead_id=lead.id
					
					if message != ''	
					urlstring =  "https://eu71.chat-api.com/instance187812/sendMessage?token=r88dlb58pg4tjvg7"
						  		result = HTTParty.get(urlstring,
								   :body => { :phone => mobile,
								              :body => message 
								              }.to_json,
								   :headers => { 'Content-Type' => 'application/json' } )
					alcove_whatsapp.message=message
					else
						urlstring =  "https://eu71.chat-api.com/instance187812/sendMessage?token=r88dlb58pg4tjvg7"
						  		result = HTTParty.get(urlstring,
								   :body => { :phone => mobile,
								              :body => "Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/918099765984?text=ExpertChat to chat with our executive.\n\nOr call us @ 8099765984\n\nThanks & Regards,\nJSB Infrastructures" 
								              }.to_json,
								   :headers => { 'Content-Type' => 'application/json' } )
					alcove_whatsapp.message="Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/918099765984?text=ExpertChat to chat with our executive.\n\nOr call us @ 8099765984\n\nThanks & Regards,\nJSB Infrastructures"
					end
					alcove_whatsapp.save
					
				end

			end	
			

			render :nothing => true, :status => 200, :content_type => 'text/html'
		end

	def rajat_chat
		if params[:type] != "error" && params[:message][:text] != nil && params[:phone_id]==21010
		body=params[:message][:text]
		mobile=params[:user][:phone]
		chat_id=params[:conversation]
		message_id=params[:message][:id]
		from_me=params[:message]['fromMe']
		replied_to_message_id=params[:message]['quotedMsgId']
		message=''
		lead_mobile=mobile[2..11]


			# body=params[:messages][0][:body]
			# mobile=params[:messages][0]['chatId'][0..11]
			# chat_id=params[:messages][0]['chatId']
			# message_id=params[:messages][0]['id']
			# from_me=params[:messages][0]['fromMe']
			# replied_to_message_id=params[:messages][0]['quotedMsgId']
			# message=''
			# lead_mobile=mobile[2..11]
			
			lead=Lead.includes(:business_unit).where(status: nil, mobile: lead_mobile, :business_units => {organisation_id: Organisation.find_by_name('Rajat Group').id})[0]
			if lead==nil
				lead=Lead.includes(:business_unit).where(status: false, mobile: lead_mobile, :business_units => {organisation_id: Organisation.find_by_name('Rajat Group').id})[0]
			end
			if body.gsub(/\s+/, '').downcase == 'interestedinsouthernvista' || body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavideeisomoy' || body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavidetoi' || body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavidesanmarg' || body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavideabp' || body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavidetelegraph'
					new_lead=Lead.new
					new_lead.mobile=mobile[2..11]
					new_lead.business_unit_id=BusinessUnit.find_by_name('Southern Vista').id
					if body.gsub(/\s+/, '').downcase == 'interestedinsouthernvista'
					new_lead.source_category_id=1230
					new_lead.name='Website Whatsapp -'+mobile
					elsif body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavideeisomoy'
					new_lead.source_category_id=1240	
					new_lead.name='Newspaper Whatsapp -'+mobile
					elsif body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavidetoi'
					new_lead.source_category_id=1241
					new_lead.name='Newspaper Whatsapp -'+mobile
					elsif body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavidesanmarg'
					new_lead.source_category_id=1319
					new_lead.name='Newspaper Whatsapp -'+mobile
					elsif body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavideabp'
					new_lead.source_category_id=1356
					new_lead.name='Newspaper Whatsapp -'+mobile
					elsif body.gsub(/\s+/, '').downcase == 'interestedinsouthernvistavidetelegraph'
					new_lead.source_category_id=3605
					new_lead.name='Newspaper Whatsapp -'+mobile
					end
					new_lead.email=''
					new_lead.customer_remarks=''
					new_lead.transfer_to_back_office
					new_lead.generated_on=Time.now
					new_lead.save

					UserMailer.new_lead_notification(new_lead).deliver
					
					# executive_number='91'+new_lead.personnel.mobile
					# if new_lead.mobile != nil && new_lead.email != nil
					# message="Source: Website, "+ new_lead.name+", "+new_lead.mobile+", "+new_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+new_lead.id.to_s).short_url
					# elsif lead.mobile != nil
					# message="Source: Website, "+ new_lead.name+", "+new_lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+new_lead.id.to_s).short_url
					# elsif lead.email != nil
					# message="Source: Website, "+ new_lead.name+", "+new_lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+new_lead.id.to_s).short_url
					# end	
					# organisation=new_lead.personnel.organisation
					# if organisation.whatsapp_instance==nil
					# urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+new_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
					# response=HTTParty.get(urlstring)
					# else

					# 	urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/"+organisation.phone_id+"/sendMessage"
					# 		  		result = HTTParty.post(urlstring,
					# 				   :body => { :to_number => "+91"+(new_lead.personnel.mobile),
				 #                		 :message => message,	
				 #                          :type => "text"
				 #                          }.to_json,
				 #                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )	
	

					# end		
			end
			project_name=lead.business_unit.name
			if lead != nil
				if project_name=='Southern Vista'
					brochure_url='https://drive.google.com/uc?id=1LiwOJ45EjdfSdB_A8CcaBr9DAzE93h42&export=download'
					plan_url='https://drive.google.com/uc?id=1ZrYpMGjgkmzD1kYTAU9QTC3VVsT8TEgU&export=download'
					payment_schedule_url='https://drive.google.com/uc?id=1A_w3poFM-EX3QtBpqficHFSiBMp0tH8s&export=download'
					photo_url='https://rajathomes.com/southern-vista/#gallery'
					location_title='Southern Vista'
					location_link='https://goo.gl/maps/u8GRmgQWnVWokVaG8'
					address="Chandpur Badehugli, Southern Bypass, Malancha, Phanri, Kolkata, West Bengal 700145"
					location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 7439941123"
					walkthrough_url="https://www.youtube.com/watch?v=lZzfZk4MLMk&t=10s"
					posession_date='October 2024'
					ongoing_rate="For queries related to price of bungalow, kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
					price_grid="https://onedrive.live.com/embed?resid=55E14145A4D50C02%21663&authkey=%21AJPnkRnGiWdP9QI&width=512&height=137"
				elsif project_name=='Aagaman'
					brochure_url="https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21590&authkey=APy-qHiNxI0uik8&em=2"
					plan_url='https://rajathomes.com/aagaman/#plans'
					photo_url='https://rajathomes.com/aagaman/#gallery'
					location_title='Aagaman by Rajat'
					location_link='https://goo.gl/maps/fNyrQHN97LQRoGGV8'
					address="591 A, Motilal Gupta Rd, Philips Colony, Tollygunge, Kolkata, West Bengal 700008"
					location_text="Timing - Monday to Sunday 10 AM to 6 PM.\n\nFor Direction Call 7439941123"
					walkthrough_url="https://youtu.be/VdlDHPzgRrU"
					price_grid="https://onedrive.live.com/embed?resid=55E14145A4D50C02%21661&authkey=%21AIOa_ciQzbyPWqA&width=512&height=133"
				end
					
				if from_me != true
					if body.gsub(/\s+/, '').downcase=='hi'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hello'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hii'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hey'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase=='hye'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase.include? 'morn'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase.include? 'noon'
						message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
					elsif body.gsub(/\s+/, '').downcase.include? 'thank'
						message="You are most welcome🙏\n\nRegards,\n"+(project_name)+"\n7439941123"
					elsif body.gsub(/\s+/, '').downcase.include? 'thx'
						message="You are most welcome🙏\n\nRegards,\n"+(project_name)+"\n7439941123"
					elsif body.gsub(/\s+/, '').downcase=='okay' || body.gsub(/\s+/, '').downcase=='ok' || body.gsub(/\s+/, '').downcase=='ohk' || body.gsub(/\s+/, '').downcase=='k' || body.gsub(/\s+/, '').downcase=='okk'
						message="Thank you for your valuable time🙏\n\nRegards,\n"+(project_name)+"\n7439941123"
					elsif body.gsub(/\s+/, '').downcase.include? 'notinterested'
						message="Thank you for your valuable time🙏\n\nRegards,\n"+(project_name)+""
					elsif body.gsub(/\s+/, '').downcase=="👍" || body.gsub(/\s+/, '').downcase=="👍🏽" || body.gsub(/\s+/, '').downcase=="👍🏻" || body.gsub(/\s+/, '').downcase=="nice" ||  body.gsub(/\s+/, '').downcase=="cool" || body.gsub(/\s+/, '').downcase=="vow" || body.gsub(/\s+/, '').downcase=="welcome" || body.gsub(/\s+/, '').downcase=="wlcm"
						message='Anytime 😎'
					elsif body.gsub(/\s+/, '').downcase=='yes'
						message="ok"
					end

										
					if body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?(':')
					  	message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\n"+(project_name)+"\n7439941123"
					elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('-')
						message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\n"+(project_name)+"\n7439941123"
					elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('am')
						message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\n"+(project_name)+"\n7439941123"
					elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('pm')
						message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\n"+(project_name)+"\n7439941123"
					else
					  
					  #multiple selections seperated by comma or and

					  number_series=body.downcase.gsub(/\s+/, '').gsub(')', '').gsub(';', '').gsub(',', '').gsub('and', '').gsub('&', '').gsub('.', '').gsub('nos', '').gsub('no', '').gsub('sl', '').gsub('/', '').gsub('send', '').gsub('n', '').gsub('to', '').gsub('-', '')

					  if number_series.length>1
					  	if number_series[0].to_i != 0 || number_series.reverse[0].to_i != 0
					  		number_length=number_series.length
					  		if number_series.reverse[0].to_i != 0 && number_series[0].to_i == 0
					  			number_series=number_series.reverse
					  		end
					  		number_length.times do |position|
					  			if number_series[position].to_i == 0
					  				message=''
					  				break
					  			elsif number_series[position]=='1'
					  				if project_name=='Southern Vista'
		  								message='👇 Brochure & Floor Plans being sent please wait...'
		  								
		  								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => mobile,
					                		 :message => brochure_url,	
					                          :text => "",
					                          :type => "media"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

								  		urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => mobile,
					                		 :message => plan_url,	
					                          :text => "",
					                          :type => "media"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
							  		elsif project_name=='Aagaman'
							  			message='👇 Brochure being sent please wait...'
		  								
		  								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => mobile,
					                		 :message => brochure_url,	
					                          :text => "",
					                          :type => "media"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

							  		end

	  				            elsif number_series[position]=='2'
	  				            		message='👇 Price Grid being sent please wait...'
		  								
		  								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
								  		result = HTTParty.post(urlstring,
										   :body => { :to_number => mobile,
					                		 :message => price_grid,	
					                          :text => "",
					                          :type => "media"
					                          }.to_json,
					                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
	  				            elsif number_series[position]=='3'
	  				            	urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => location_link,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            

	  				                message=location_text
	  							elsif number_series[position]=='4'
	  								message=photo_url
	  							elsif number_series[position]=='5'
	  								message=walkthrough_url
	  							elsif number_series[position]=='6'
	  								if project_name=='Southern Vista'
	  								message=posession_date
	  								elsif project_name=='Aagaman'
	  								message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"	
	  								end	
	  							elsif number_series[position]=='7'
	  								if project_name=='Southern Vista'
	  								message='👇 Payment Schedule being sent please wait...'
	  								
	  								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => payment_schedule_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
							  		elsif project_name=='Aagaman'
							  			message="Kindly click: https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"
							  		end 
	  							elsif number_series[position]=='8'
	  								message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
	  							elsif number_series[position]=='9'
	  								message="Kindly click: https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"
	  							end

					  			if position < (number_length-1)
					  			urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => message,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                            
	
					  			end
					  		end
					  	end
					  end
					end	

					if body.gsub(/\s+/, '')=='1'
		  				if project_name=='Southern Vista'
								message='👇 Brochure & Floor Plans being sent please wait...'
								
								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
					  		result = HTTParty.post(urlstring,
							   :body => { :to_number => mobile,
		                		 :message => brochure_url,	
		                          :text => "",
		                          :type => "media"
		                          }.to_json,
		                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

					  		urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
					  		result = HTTParty.post(urlstring,
							   :body => { :to_number => mobile,
		                		 :message => plan_url,	
		                          :text => "",
		                          :type => "media"
		                          }.to_json,
		                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
				  		elsif project_name=='Aagaman'
				  			message='👇 Brochure being sent please wait...'
								
								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
					  		result = HTTParty.post(urlstring,
							   :body => { :to_number => mobile,
		                		 :message => brochure_url,	
		                          :text => "",
		                          :type => "media"
		                          }.to_json,
		                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

				  		end	  		
						
					elsif body.gsub(/\s+/, '')=='2'
								message='👇 Price Grid being sent please wait...'
								
								urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
					  		result = HTTParty.post(urlstring,
							   :body => { :to_number => mobile,
		                		 :message => price_grid,	
		                          :text => "",
		                          :type => "media"
		                          }.to_json,
		                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
					  	
					elsif body.gsub(/\s+/, '')=='3'
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => location_link,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                           

		                message=location_text
					elsif body.gsub(/\s+/, '')=='4'
						message=photo_url
					elsif body.gsub(/\s+/, '')=='5'
						message=walkthrough_url
					elsif body.gsub(/\s+/, '')=='6'
						if project_name=='Southern Vista'
						message=posession_date
						elsif project_name=='Aagaman'
						message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"	
						end
					elsif body.gsub(/\s+/, '')=='7'
						if project_name=='Southern Vista'
							message='👇 Payment Schedule being sent please wait...'
							
							urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
				  		result = HTTParty.post(urlstring,
						   :body => { :to_number => mobile,
	                		 :message => payment_schedule_url,	
	                          :text => "",
	                          :type => "media"
	                          }.to_json,
	                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
				  		elsif project_name=='Aagaman'
				  			message="Kindly click: https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"
				  		end
					elsif body.gsub(/\s+/, '')=='8'
						message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
					elsif body.gsub(/\s+/, '')=='9'
						message='Kindly click: https://wa.me/91'+(lead.personnel.mobile)+'?text=ExpertChat'
					end

					if body.gsub(/\s+/, '').downcase.include?('brochur') || 
						body.gsub(/\s+/, '').downcase.include?('facilit') || 
						body.gsub(/\s+/, '').downcase.include?('specific') || 
						body.gsub(/\s+/, '').downcase.include?('ameni')
						message='👇 Brochure being sent please wait...'

						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

					elsif body.gsub(/\s+/, '').downcase.include? 'projectdetail'
						message='👇 Brochure being sent please wait...'

						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

		            elsif body.gsub(/\s+/, '').downcase.include? 'plan'
						if project_name=='Southern Vista'
						message='👇 Floor Plans being sent please wait...'

						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => plan_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
						elsif project_name=='Aagaman'
							message=plan_url
						end	  		
		            elsif body.gsub(/\s+/, '').downcase.include?('locat') || 
		            	body.gsub(/\s+/, '').downcase.include?('map') || 
		            	body.gsub(/\s+/, '').downcase.include?('address') || 
		            	body.gsub(/\s+/, '').downcase.include?('beyond') || 
		            	body.gsub(/\s+/, '').downcase.include?('beside') || 
		            	body.gsub(/\s+/, '').downcase.include?('near') || 
		            	body.gsub(/\s+/, '').downcase.include?('where') || 
		            	body.gsub(/\s+/, '').downcase.include?('north') || 
		            	body.gsub(/\s+/, '').downcase.include?('south') || 
		            	body.gsub(/\s+/, '').downcase.include?('west') || 
		            	body.gsub(/\s+/, '').downcase.include?('east') || 
		            	body.gsub(/\s+/, '').downcase.include?('around')
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => location_link,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                           

		                message=location_text
					elsif body.gsub(/\s+/, '').downcase.include?('gallery') || 
						body.gsub(/\s+/, '').downcase.include?('video') || 
						body.gsub(/\s+/, '').downcase.include?('photo') || 
						body.gsub(/\s+/, '').downcase.include?('pic')		
   						message=photo_url
					elsif body.gsub(/\s+/, '').downcase.include? 'payment'
						if project_name=='Southern Vista'
						message='👇 Payment Schedule being sent please wait...'
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => payment_schedule_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
						elsif project_name=='Aagaman'
						message="For Payment related assistance kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)	
						end
					elsif body.gsub(/\s+/, '').downcase.include? 'emi'
						message="For EMI related assistance kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
					elsif body.gsub(/\s+/, '').downcase.include? 'availabl'
						message="For availability related queries kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
					elsif body.gsub(/\s+/, '').downcase.include? 'loan'
						message="For loan related assistance kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
					elsif body.gsub(/\s+/, '').downcase.include? 'bank'
						message="For loan related assistance kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
					elsif body.gsub(/\s+/, '').downcase.include? 'rate'
						if ongoing_rate==nil
						message="For Rate related queries kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
						else
						message=ongoing_rate
						end
					elsif body.gsub(/\s+/, '').downcase.include?('posess') || 
						body.gsub(/\s+/, '').downcase.include?('possess') || 
						body.gsub(/\s+/, '').downcase.include?('complet') || 
						body.gsub(/\s+/, '').downcase.include?('handover') || 
						body.gsub(/\s+/, '').downcase.include?('deliver')
						if posession_date==nil
						message="For Posession related queries kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
						else 
						message=posession_date
						end
					elsif body.gsub(/\s+/, '').downcase.include?('bhk') || 
						body.gsub(/\s+/, '').downcase.include?('cost') || 
						body.gsub(/\s+/, '').downcase.include?('price') || 
						body.gsub(/\s+/, '').downcase.include?('budget') 	
						message='👇 Price Grid being sent please wait...'
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => price_grid,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
					elsif body.gsub(/\s+/, '').downcase.include?('totalarea') || 
						body.gsub(/\s+/, '').downcase.include?('landarea') || 
						body.gsub(/\s+/, '').downcase.include?('areaofland')
						message="For land area, kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+" to chat with our executive.\n\nOr call us @ "+(lead.personnel.mobile)
					elsif body.gsub(/\s+/, '').downcase.include?('book') || 
						body.gsub(/\s+/, '').downcase.include?('visit') || 
						body.gsub(/\s+/, '').downcase.include?('appoint')	
						message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
					elsif body.gsub(/\s+/, '').downcase.include?('chat') || 
						body.gsub(/\s+/, '').downcase.include?('expert') || 
						body.gsub(/\s+/, '').downcase.include?('human') || 
						body.gsub(/\s+/, '').downcase.include?('person') || 
						body.gsub(/\s+/, '').downcase.include?('executive') || 
						body.gsub(/\s+/, '').downcase.include?('someone') || 
						body.gsub(/\s+/, '').downcase.include?('somebody') 
						message='Kindly click: https://wa.me/91'+(lead.personnel.mobile)+'?text=ExpertChat'
					elsif body.gsub(/\s+/, '').downcase.include?('about') || 
						body.gsub(/\s+/, '').downcase.include?('company') || 
						body.gsub(/\s+/, '').downcase.include?('builder') || 
						body.gsub(/\s+/, '').downcase.include?('profile')
						message='Kindly click: https://wa.me/91'+(lead.personnel.mobile)+'?text=ExpertChat'
					elsif body.gsub(/\s+/, '').downcase.include?('call') || 
						body.gsub(/\s+/, '').downcase.include?('talk') || 
						body.gsub(/\s+/, '').downcase.include?('help') || 
						body.gsub(/\s+/, '').downcase.include?('assist') || 
						body.gsub(/\s+/, '').downcase.include?('contactme') || 
						body.gsub(/\s+/, '').downcase.include?('getintouch')
						message="Our executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+(lead.personnel.mobile)+"?text=ExpertChat"+"\n\nOr you can initiate a call @ "+(lead.personnel.mobile)
					elsif body.gsub(/\s+/, '').downcase.include? 'detail'
						message='👇 Brochure being sent please wait...'
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => brochure_url,	
				                          :text => "",
				                          :type => "media"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
					end
					lead_whatsapp=Whatsapp.new
					lead_whatsapp.lead_id=lead.id
					lead_whatsapp.by_lead=true
					lead_whatsapp.message=body
					lead_whatsapp.save

					alcove_whatsapp=Whatsapp.new
					alcove_whatsapp.lead_id=lead.id
					
					if message != ''
					urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => message,	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                           
					alcove_whatsapp.message=message
					else
						urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
							  		result = HTTParty.post(urlstring,
									   :body => { :to_number => mobile,
				                		 :message => "Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/917439941123?text=ExpertChat to chat with our executive.\n\nOr call us @ 7439941123\n\nThanks & Regards,\n"+(project_name),	
				                          :type => "text"
				                          }.to_json,
				                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )                           
					alcove_whatsapp.message="Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/917439941123?text=ExpertChat to chat with our executive.\n\nOr call us @ 7439941123\n\nThanks & Regards,\n"+(project_name)
					end
					alcove_whatsapp.save
					
				end

			end	
			

			render :nothing => true, :status => 200, :content_type => 'text/html'
		end
	end	
	def ifttt_call_capture
		p "working"
		p params
		p "=====================-----------------=========================="
		personnel = Personnel.where(mobile: params[:from], access_right: 2)[0]
		daily_calling = DailyCalling.new
		daily_calling.personnel_id = personnel.id
		daily_calling.date = params[:occurred_at].to_datetime
		daily_calling.called_number = params[:mobile]
		daily_calling.duration = params[:duration]
		if (lead = Lead.where(mobile: params[:mobile], booked_on: nil, business_unit_id: personnel.business_unit_id, personnel_id: personnel.id)) != []
			daily_calling.lead_id = lead[0].id
		elsif (lead = Lead.where(mobile: params[:mobile], booked_on: nil, business_unit_id: personnel.business_unit_id)) != []
			daily_calling.lead_id = lead[0].id
		elsif (lead = Lead.where(mobile: params[:mobile], booked_on: nil)) != []
			daily_calling.lead_id = lead[0].id
		elsif (lead = Lead.where(mobile: params[:mobile], business_unit_id: personnel.business_unit_id, personnel_id: personnel.id).where.not(booked_on: nil)) != []
			lead = lead.sort_by{|x| x.updated_at}.last
			daily_calling.lead_id = lead.id
		elsif (lead = Lead.where(mobile: params[:mobile], business_unit_id: personnel.business_unit_id).where.not(booked_on: nil)) != []
			lead = lead.sort_by{|x| x.updated_at}.last
			daily_calling.lead_id = lead.id
		elsif (lead = Lead.where(mobile: params[:mobile]).where.not(booked_on: nil)) != []
			lead = lead.sort_by{|x| x.updated_at}.last
			daily_calling.lead_id = lead.id
		else
			# no lead id
		end
		daily_calling.save
		render :nothing => true		
	end	

	def phone_call_report
		if params[:from] == nil
			@from = DateTime.now.beginning_of_day
			@to = DateTime.now.end_of_day
			@daily_callings = DailyCalling.where('date >= ? AND date <= ?', @from, @to).group_by{|x| x.personnel_id}
		else
			@from = params[:from]
			@to = params[:to]
			@daily_callings = DailyCalling.where('date >= ? AND date <= ?', @from.to_datetime.beginning_of_day, @to.to_datetime.end_of_day).group_by{|x| x.personnel_id}
		end
	end

	def super_receptionist
		telephony_call = TelephonyCall.new
		telephony_call.duration = params[:webhook][:call_duration].split(':').map(&:to_i).inject(0) { |a, b| a * 60 + b }.to_f
		telephony_call.recording_url = params[:webhook][:call_recording]
		telephony_call.k_number = params[:webhook][:knowlarity_number]
		telephony_call.start_time = params[:webhook][:start_time]
		telephony_call.call_type = params[:webhook][:call_type]
		telephony_call.call_outcome = params[:webhook][:call_outcome]
		telephony_call.agent_number = params[:webhook][:agent_number][3..params[:webhook][:agent_number].length]
		telephony_call.customer_number = params[:webhook][:customer_number][3..params[:webhook][:customer_number].length]
		telephony_call.untagged = true
		telephony_call.save
		broker_contact = nil
		if telephony_call.k_number.include?("9513436775") == true
			p "================inserted in to the broker section=================="
			if BrokerContact.where(mobile_one: telephony_call.customer_number) == []
				if BrokerContact.where(mobile_two: telephony_call.customer_number) == []
					broker = Broker.new
					broker.name = "Fresh Incoming Call Broker"
					broker.save

					broker_project_status = BrokerProjectStatus.new
			        broker_project_status.broker_id = broker.id
			        broker_project_status.business_unit_id = 70
			        broker_project_status.save

			        broker_contact_data = BrokerContact.new
			        broker_contact_data.broker_id = broker.id
			        broker_contact_data.name = "Incoming Call-"+telephony_call.customer_number.to_s
			        broker_contact_data.mobile_one = telephony_call.customer_number
			        broker_contact_data.personnel_id = Personnel.where(mobile: telephony_call.agent_number).where('access_right = ? OR access_right = ? OR access_right is ?', 2)[0].id
			        broker_contact_data.save
			        broker_contact = broker_contact_data
				else
					broker_contact = BrokerContact.where(mobile_two: telephony_call.customer_number)[0]
				end
			else
				broker_contact = BrokerContact.where(mobile_one: telephony_call.customer_number)[0]
				personnels = Personnel.where(mobile: telephony_call.agent_number, access_right: [2, nil])
				if personnel == []
				elsif personnels.count == 1
					if broker_contact.personnel_id == personnels[0].id
					else
						broker_contact.update(personnel_id: personnels[0].id)
					end
				end
			end
			data = [broker_contact.id, telephony_call.agent_number, telephony_call.customer_number]
			p data
			p "=============bc data============"
			UserMailer.broker_contact_data_mail(data).deliver
			p "===========mail sent============"
		end
		p "=================================="
		p telephony_call.agent_number
		p telephony_call.id
		p "====================================="
		if params[:webhook][:agent_number] == 'False' || params[:webhook][:agent_number] == 'None'
		else
			p "=================================="
			p "inserting into the trigger section"
			p "=================================="
			Pusher['telephony_channel'].trigger('push_telephony_call_id', { :telephony_call_id => [telephony_call.id], :personnel_id => [Personnel.where(mobile: telephony_call.agent_number).where('access_right = ? OR access_right = ? OR access_right is ?', 2, 4, nil)[0].id] })
		end
		@sr = telephony_call.k_number
		@lead_number = telephony_call.customer_number
		@destination = telephony_call.call_type
		organisation = Organisation.find(1)
		marketing_number = MarketingNumber.find_by_number(@sr)
		if BrokerContact.where('mobile_one = ? OR mobile_two = ?', telephony_call.customer_number, telephony_call.customer_number) == []
			if marketing_number != nil
				@marketing_number_id = marketing_number.id
				if Lead.joins(:personnel).where(:personnels => {organisation_id: marketing_number.organisation_id}, :leads => {mobile: @lead_number, business_unit_id: marketing_number.business_unit_id, status: false}) != []
					puts 'duplicate'
					Lead.joins(:personnel).where(:personnels => {organisation_id: marketing_number.organisation_id}, :leads => {mobile: @lead_number, business_unit_id: marketing_number.business_unit_id, status: false}).each do |lead|
						if lead.lost_reason_id == nil
							telephony_call.update(fresh: false, lead_id: lead.id)
							break
						end
					end
					auto_lead = Lead.new
					auto_lead.name = @sr+' - '+ @destination
					auto_lead.mobile = telephony_call.customer_number
					auto_lead.business_unit_id = marketing_number.business_unit_id
					auto_lead.source_category_id = marketing_number.source_category_id
					auto_lead.generated_on = Time.now
					auto_lead.duplicate_capture(Lead.joins(:personnel).where(:personnels => {organisation_id: marketing_number.organisation_id}, :leads => {mobile: @lead_number, business_unit_id: marketing_number.business_unit_id, status: false})[0])
							
				elsif Lead.joins(:personnel).where(:personnels => {organisation_id: marketing_number.organisation_id}, :leads => {mobile: @lead_number, business_unit_id: marketing_number.business_unit_id, status: nil}) != []	
					puts 'duplicate'
					Lead.joins(:personnel).where(:personnels => {organisation_id: marketing_number.organisation_id}, :leads => {mobile: @lead_number, business_unit_id: marketing_number.business_unit_id, status: nil}).each do |lead|
						if lead.lost_reason_id == nil
							telephony_call.update(fresh: false, lead_id: lead.id)
							break
						end
					end

					auto_lead = Lead.new
					auto_lead.name = @sr+' - '+ @destination
					auto_lead.mobile = telephony_call.customer_number
					auto_lead.business_unit_id = marketing_number.business_unit_id
					auto_lead.source_category_id = marketing_number.source_category_id
					auto_lead.generated_on = Time.now
					auto_lead.duplicate_capture(Lead.joins(:personnel).where(:personnels => {organisation_id: marketing_number.organisation_id}, :leads => {mobile: @lead_number, business_unit_id: marketing_number.business_unit_id, status: nil})[0])

				else	  
					@lead = Lead.new
					@lead.name = @sr+' - '+ @destination
					@lead.mobile = telephony_call.customer_number
					@lead.business_unit_id = marketing_number.business_unit_id
					# @lead.source_category_id = 868
					@lead.source_category_id = marketing_number.source_category_id
					if params[:webhook][:agent_number] == 'False' || params[:webhook][:agent_number] == 'None'
						if organisation.holiday == true
							@lead.transfer_to_back_office
						elsif organisation.auto_allocate == true || @lead.business_unit.auto_allocate == true
							@lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).sunday?
							@lead.transfer_to_back_office
						elsif (Time.now+5.hours+30.minutes).saturday?
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
								@lead.transfer_to_back_office
							else
								@lead.transfer_to_back_office
							end		
						else
							if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
								@lead.transfer_to_back_office
							else
								@lead.transfer_to_back_office
							end
						end
					else
						@lead.transfer_to_back_office
						@lead.personnel_id = Personnel.where(mobile: telephony_call.agent_number).where('access_right = ? OR access_right = ? OR access_right is ?', 2, 4, nil)[0].id
					end
					# if params[:webhook][:agent_number] != 'False' || params[:webhook][:agent_number] != 'None'
					# 	@lead.transfer_to_back_office
					# 	@lead.personnel_id = Personnel.where(mobile: telephony_call.agent_number).where('access_right = ? OR access_right = ? OR access_right is ?', 2, 4, nil)[0].id
					# else
					# 	if organisation.holiday == true
					# 		@lead.transfer_to_back_office
					# 	elsif organisation.auto_allocate == true || @lead.business_unit.auto_allocate == true
					# 		@lead.transfer_to_back_office
					# 	elsif (Time.now+5.hours+30.minutes).sunday?
					# 		@lead.transfer_to_back_office
					# 	elsif (Time.now+5.hours+30.minutes).saturday?
					# 		if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
					# 			@lead.transfer_to_back_office
					# 		else
					# 			@lead.transfer_to_back_office
					# 		end		
					# 	else
					# 		if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
					# 			@lead.transfer_to_back_office
					# 		else
					# 			@lead.transfer_to_back_office
					# 		end
					# 	end
					# end
					@lead.generated_on = Time.now
					@lead.save
					telephony_call.update(lead_id: @lead.id, fresh: true, untagged: nil)
				end
			else
				if params[:webhook][:agent_number] == 'False' || params[:webhook][:agent_number] == 'None'
				else
					personnel = Personnel.where(mobile: params[:webhook][:agent_number][3..params[:webhook][:agent_number].length]).where('access_right = ? OR access_right = ? OR access_right is ?', 2, 4, nil)[0]
					lead = Lead.where(mobile: params[:webhook][:customer_number][3..params[:webhook][:customer_number].length], personnel_id: personnel.id).sort_by{|x| x.created_at}.last
					if lead == nil
						@lead = Lead.new
						@lead.name = @sr+' - '+ @destination
						@lead.mobile = telephony_call.customer_number
						@lead.business_unit_id = personnel.business_unit_id
						@lead.source_category_id = 868
						# if telephony_call.agent_number != 'False'
						@lead.transfer_to_back_office	
						@lead.personnel_id = Personnel.where(mobile: telephony_call.agent_number).where('access_right = ? OR access_right = ? OR access_right is ?', 2, 4, nil)[0].id
						# else
						# 	if organisation.holiday == true
						# 		@lead.transfer_to_back_office
						# 	elsif organisation.auto_allocate == true || @lead.business_unit.auto_allocate == true
						# 		@lead.transfer_to_back_office
						# 	elsif (Time.now+5.hours+30.minutes).sunday?
						# 		@lead.transfer_to_back_office
						# 	elsif (Time.now+5.hours+30.minutes).saturday?
						# 		if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+16.hours)
						# 			@lead.transfer_to_back_office
						# 		else
						# 			@lead.transfer_to_back_office
						# 		end		
						# 	else
						# 		if (Time.now+5.hours+30.minutes).between?((Time.now+5.hours+30.minutes).beginning_of_day+10.hours, (Time.now+5.hours+30.minutes).beginning_of_day+19.hours)
						# 			@lead.transfer_to_back_office
						# 		else
						# 			@lead.transfer_to_back_office
						# 		end
						# 	end
						# end
						@lead.generated_on = Time.now
						@lead.save
						telephony_call.update(lead_id: @lead.id, fresh: true, untagged: nil)
					else
						telephony_call.update(fresh: false, lead_id: lead.id)
					end
				end
		 	end
		end
	 	render :nothing => true
	end

def webhook_chat
	if params[:type] != "error" && params[:type] != "ack" && params[:message][:text] != nil && params[:phone_id]==21763
		body=params[:message][:text]
		mobile=params[:user][:phone]
		chat_id=params[:conversation]
		message_id=params[:message][:id]
		from_me=params[:message]['fromMe']
		replied_to_message_id=params[:message]['quotedMsgId']
		message=''
		mobile=mobile[2..11]	
		# caption=params[:messages][0][:caption]
		outstanding_projects=[['topoutstanding0','All'],['topoutstanding1','DREAM ONE BLK 1 \ 2'],['topoutstanding2','DREAM ONE BLK 3 \ 4'],['topoutstanding3','DREAM GATEWAY PAILAN PROJECTS'],['topoutstanding4','DREAM JAIN-PAILAN'],['topoutstanding5','DREAM VALLEY'],['topoutstanding6','DREAM ECOCITY']]
		training_video_links=[['fms01','FMS 01','https://www.youtube.com/embed/aCVllRiCQ34'],['fms02','FMS 02','https://www.youtube.com/embed/TerqqIzVRHI'],['fms03','FMS 03','https://www.youtube.com/embed/E1N5HiRg_iU'],['fms04','FMS 04','https://www.youtube.com/embed/ZQo_dF9KI8k'],['fms05','FMS 05','https://www.youtube.com/embed/8tnBZViAzvI'],['fms06','FMS 06','https://www.youtube.com/embed/ACf1BBONDbA'],['fms07','FMS 07','https://www.youtube.com/embed/MY0ywYbrM4w'],['marketingfms1','Marketing FMS 1','https://www.youtube.com/embed/oYDQLYgi9MM'],['marketingfms2','Marketing FMS 2','https://www.youtube.com/embed/kjWL-mWrges'],['marketingfms3','Marketing FMS 3','https://www.youtube.com/embed/uYljAfsm4oo'],['marketingfms4','Marketing FMS 4','https://www.youtube.com/embed/x9cwC2oXYk4'],['marketingfms5','Marketing FMS 5','https://www.youtube.com/embed/MrlWswqDODw'],['finance1','Finance 1','https://www.youtube.com/embed/tiQrC9QwDxg'],['finance2','Finance 2','https://www.youtube.com/embed/JwSVZI0b0CE'],['crmpart1','CRM Part 1','https://www.youtube.com/embed/ET1PgQR3lb0'],['crmpart2','CRM Part 2','https://www.youtube.com/embed/EdSyWryDuLQ'],['tagatask1','TagATask 1','https://www.youtube.com/embed/m7i-yHLEzfE'],['tagatask2','TagATask 2','https://www.youtube.com/embed/EVZ0n7lwBa8'],['inoxpart1','Inox Part 1','https://www.youtube.com/embed/97Z1zeytzOI'],['workschedulepart1','Work Schedule Part 1','https://www.youtube.com/embed/636VZ2wILFk'],['workschedulepart2','Work Schedule Part 2','https://www.youtube.com/embed/AgWP2nqzMb8']]
		vendors=[['jalaluddin','JALALUDDIN'],['magicbricks','MAGICBRICKS.COM'],['rajyatayat','RAJ YATAYAT (P) LTD.'],['garudapower','GARUDA POWER PVT LTD'],['bajajallianz','BAJAJ ALLIANZ GENERAL INSURANCE CO LTD.'],['autoenergy','AUTO ENERGY'],['wbse','WEST BENGAL STATE ELECTRICITY DISTRIBUTION CO LTD'],['hygeine','HYGENIE'],['livhousing','LIVHOUSING ESERVICES PVT LTD'],['indusnet','INDUS NET TECHNOLOGIES PVT LTD'],['tataaig','TATA AIG GENERAL INSURANCE COMPANY LTD'],['kdsecurity','K D SECURITY SERVICE'],['airtel','AIRTEL LTD'],['redpencil','RED PENCIL CREATIONS'],['selvel','SELVEL ADVERTISING PVT LTD'],['fragua','FRAGUA TECHNOLOGIES (INDIA) PVT LTD'],['standardvulcanizing','STANDARD VULCANIZING CORPORATION'],['swadeshsoftwares','SWADESH SOFTWARES PVT LTD']]	
		if from_me != true
			## frankross pilot		
			if body.include? ('https://www.facebook.com/thejaingroup')
				message="*Welcome to Jain Group*\n\nIf you are interested in our Dream One, Rajarhat project type *Rajarhat*\n\nIf you are interested in our Dream World City, Joka project please type *Joka*\n\nThanks & Regards,\nwww.thejaingroup.com"
			end					
			if body.gsub(/\s+/, '').downcase == 'interestedindreamecocitybungalows'
				fb_project=CGI.escape('Ecocity Bungalows')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end
			if body.gsub(/\s+/, '').downcase == 'interestedindreamexotica'
				fb_project=CGI.escape('Dream Exotica')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end
			if body.gsub(/\s+/, '').downcase == 'interestedindreampalazzo'
				fb_project=CGI.escape('Dream Palazzo')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end

			if body.gsub(/\s+/, '').downcase == 'interestedindreamecocity'
				fb_project=CGI.escape('Dream Eco City')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end

			if body.gsub(/\s+/, '').downcase == 'interestedindreamone'
				fb_project=CGI.escape('Dream One')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end

			if body.gsub(/\s+/, '').downcase == 'interestedindreamworldcity'
				fb_project=CGI.escape('Dream World City')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end

			if body.gsub(/\s+/, '').downcase == 'interestedindreamonehotel'
				fb_project=CGI.escape('Dream One Hotel Apartment')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end

			if body.gsub(/\s+/, '').downcase == 'interestedindreamvalley'
				fb_project=CGI.escape('Dream Valley')
				urlstring =  "https://www.realtybucket.com/webhook/microsite_whatsapp_lead_create?mobile="+(mobile)+'&project='+fb_project
	            fb_whatsapp_result = HTTParty.get(urlstring)
	            # create lead in dream one
				# send courtesy message
			end
					# if 'reorderpilot'.include? (body.gsub(/\s+/, '').downcase)
					# 	message='Instamet due for purchase, to reorder click https://bit.ly/2C75XrG'
					# end

					

					if message != ''

					urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
            		@result = HTTParty.post(urlstring,
               		:body => { :to_number => "+91"+mobile,
                 	:message => message,    
                  	:type => "text"
                  	}.to_json,
                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

					# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
					# 	  		result = HTTParty.get(urlstring,
					# 			   :body => { :phone => mobile,
					# 			              :body => message 
					# 			              }.to_json,
					# 			   :headers => { 'Content-Type' => 'application/json' } )
					else
						p '1822 null message'
					end

					# urlstring =  "https://scheduleupdates.herokuapp.com/activity/genie_lamp.json"
					# result = HTTParty.get(urlstring)
					# genie_lamp=result['genie_lamp']

					# training_video_links+=genie_lamp	

					# selected_links=training_video_links.select{|video_link| video_link[0].include? (body.gsub(/\s+/, '').downcase)}

					# urlstring =  "https://postcrm.herokuapp.com/window/mobile_check?mobile="+mobile
		   #          customer_result = HTTParty.get(urlstring)

		   #          urlstring =  "https://postcrm.herokuapp.com/window/chat_id_check?chat_id="+chat_id
		   #          executive_result = HTTParty.get(urlstring)

     #    			if customer_result.parsed_response == 'false'
     #    			urlstring =  "https://www.realtybucket.com/webhook/mobile_check?mobile="+(mobile)
     #                customer_result = HTTParty.get(urlstring)
     #            	end

     #            	if executive_result.parsed_response == 'false'
     #    			urlstring =  "https://www.realtybucket.com/webhook/chat_id_check?chat_id="+chat_id
     #                executive_result = HTTParty.get(urlstring)
     #            	end

					# # post sales chat customer
					# if customer_result.parsed_response != 'false' && from_me != true
					# # whatsapp message sent by customer being forwarded to group...executive	
					
					# customer_chat_id=customer_result.parsed_response
					# 	if replied_to_message_id != nil
					# 	urlstring =  "https://eu71.chat-api.com/instance124988/forwardMessage?token=awjkvkwi2sdzv65j"
					# 	     result = HTTParty.get(urlstring,
					# 	 :body => { :chatId => customer_chat_id,
					# 	           :messageId => replied_to_message_id  
					# 	           }.to_json,
					# 	:headers => { 'Content-Type' => 'application/json' } )
					# 	end
						
					# 	if body.include? ('s3.eu-central')
					# 		# position of ,
					# 		# position of dot before ,
					# 		# get filename from between the above two
					# 		link_ending=body.index(',')
					# 		file_type=''
					# 		5.times do |count|
					# 			if body[link_ending-1-count]=='.'
					# 				file_type=body[(link_ending-count)..(link_ending-1)]
					# 			end
					# 		end
					# 		file_content=body[0..link_ending]
							
					# 			urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
					# 	            result = HTTParty.get(urlstring,
					# 	        :body => { :chatId => customer_chat_id,
					# 	                  :body => file_content,
					# 	                  :filename => 'customerfile.'+file_type  
					# 	                  }.to_json,
					# 	       :headers => { 'Content-Type' => 'application/json' } )
						    
					# 	elsif body.include? ('BEGIN:VCARD')
					# 	v_card_text=body
					# 	v_card_text[11]=''
					# 	v_card_text.insert(11, "\n")

					# 	 urlstring =  "https://eu71.chat-api.com/instance124988/sendVcard?token=awjkvkwi2sdzv65j"
					# 	             result = HTTParty.get(urlstring,
					# 	         :body => { :chatId => customer_chat_id,
					# 	                    :vcard => v_card_text
					# 	                   }.to_json,
					# 	        :headers => { 'Content-Type' => 'application/json' })

					# 	 elsif body.include? ('Video upload disabled')
						
					# 	 urlstring =  "https://eu71.chat-api.com/instance124988/forwardMessage?token=awjkvkwi2sdzv65j"
					# 	     result = HTTParty.get(urlstring,
					# 	 :body => { :chatId => customer_chat_id,
					# 	           :messageId => message_id  
					# 	           }.to_json,
					# 	:headers => { 'Content-Type' => 'application/json' } )    

				 #       elsif body[18]==';'
					# 	urlstring =  "https://eu71.chat-api.com/instance124988/sendLocation?token=awjkvkwi2sdzv65j"
				 #            result = HTTParty.get(urlstring,
				 #        :body => { :chatId => customer_chat_id,
				 #                  :lat => body[0..17].to_f,
				 #                  :lng => body[19..35].to_f,
				 #                  :address => ''
				 #                  }.to_json,
				 #       :headers => { 'Content-Type' => 'application/json' } )
				 #       else

				 #       		if caption != nil
				 #       			body=body+" , "+caption
				 #       		end

					# 	urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
				 #            result = HTTParty.get(urlstring,
				 #        :body => { :chatId => customer_chat_id,
				 #                  :body => body  
				 #                  }.to_json,
				 #       :headers => { 'Content-Type' => 'application/json' } )
				 #        end
					## post sales chat executive
					# elsif executive_result.parsed_response != 'false' && from_me != true
					# # whatsapp message sent by executive being forwarded to customer	
					# # check if chat id exists in postcrm
					# # then forward to customer
					# 		customer_number=executive_result.parsed_response
					# 			if replied_to_message_id != nil
					# 			urlstring =  "https://eu71.chat-api.com/instance124988/forwardMessage?token=awjkvkwi2sdzv65j"
					# 			     result = HTTParty.get(urlstring,
					# 			 :body => { :phone => customer_number,
					# 			           :messageId => replied_to_message_id  
					# 			           }.to_json,
					# 			:headers => { 'Content-Type' => 'application/json' } )
					# 			end
								
					# 			if body.include? ('s3.eu-central')
					# 				# position of ,
					# 				# position of dot before ,
					# 				# get filename from between the above two
					# 				link_ending=body.index(',')
					# 				file_type=''
					# 				5.times do |count|
					# 					if body[link_ending-1-count]=='.'
					# 						file_type=body[(link_ending-count)..(link_ending-1)]
					# 					p file_type
					# 					end
					# 				end
					# 				file_content=body[0..link_ending]
					# 					urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
					# 			            result = HTTParty.get(urlstring,
					# 			        :body => { :phone => customer_number,
					# 			                  :body => file_content,
					# 			                  :filename => 'customerfile.'+file_type  
					# 			                  }.to_json,
					# 			       :headers => { 'Content-Type' => 'application/json' } )
								    
					# 			elsif body.include? ('BEGIN:VCARD')
					# 			v_card_text=body
					# 			v_card_text[11]=''
					# 			v_card_text.insert(11, "\n")

					# 			 urlstring =  "https://eu71.chat-api.com/instance124988/sendVcard?token=awjkvkwi2sdzv65j"
					# 			             result = HTTParty.get(urlstring,
					# 			         :body => { :phone => customer_number,
					# 			                    :vcard => v_card_text
					# 			                   }.to_json,
					# 			        :headers => { 'Content-Type' => 'application/json' })

					# 			 elsif body.include? ('Video upload disabled')
								
					# 			 urlstring =  "https://eu71.chat-api.com/instance124988/forwardMessage?token=awjkvkwi2sdzv65j"
					# 			     result = HTTParty.get(urlstring,
					# 			 :body => { :phone => customer_number,
					# 			           :messageId => message_id  
					# 			           }.to_json,
					# 			:headers => { 'Content-Type' => 'application/json' } )    

					# 	       elsif body[18]==';'
					# 			urlstring =  "https://eu71.chat-api.com/instance124988/sendLocation?token=awjkvkwi2sdzv65j"
					# 	            result = HTTParty.get(urlstring,
					# 	        :body => { :phone => customer_number,
					# 	                  :lat => body[0..17].to_f,
					# 	                  :lng => body[19..35].to_f,
					# 	                  :address => ''
					# 	                  }.to_json,
					# 	       :headers => { 'Content-Type' => 'application/json' } )
					# 	       else

					# 	       	if caption != nil
					# 	       		body=body+" , "+caption
					# 	       	end

					# 			urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
					# 	            result = HTTParty.get(urlstring,
					# 	        :body => { :phone => customer_number,
					# 	                  :body => body  
					# 	                  }.to_json,
					# 	       :headers => { 'Content-Type' => 'application/json' } )
					# 	        end
						
					if Personnel.find_by(mobile: (mobile), organisation_id: 310) != nil
							if body.gsub(/\s+/, '').downcase.length <= 2
							elsif 'trainingvideos'.include? (body.gsub(/\s+/, '').downcase)
								training_video_links.each do |link|
								message+=link[1]+"\n"+link[2]+"\n\n"
								end
							# elsif selected_links !=[]
							# 	selected_links.each do |link|
							# 	message+=link[1]+"\n"+link[2]+"\n\n"
							# 	end
							elsif 'attendance'.include? (body.gsub(/\s+/, '').downcase)
								gps_punches=GpsPunch.includes(:personnel).where(:personnels => {organisation_id: 3}).where('gps_punches.created_at > ?', Time.now.beginning_of_day)
								biometric_punches=BiometricPunch.includes(:client_device).where(:client_devices => {organisation_id: 3}).where('biometric_punches.created_at > ?', Time.now.beginning_of_day)
								present=[]
								remote_present=[]

								gps_punches.each do |gps_present|
									# if gps_present.personnel.geo_fence_lat == nil || gps_present.personnel.geo_fence_lat == ''
									present+=[gps_present.personnel.name]
									# else
									# 	distance = Geocoder::Calculations.distance_between([gps_present.personnel.geo_fence_lat,gps_present.personnel.geo_fence_long], [gps_present.latitude,gps_present.longitude])
									# 	if distance > 1
									# 	remote_present+=[gps_present.personnel.name]	
									# 	else
									# 	present+=[gps_present.personnel.name]	
									# 	end	
									# end				
								end

								biometric_punches.each do |biometric_present|
									present+=[BiometricId.find_by(box_id: biometric_present.box_id, impression_id: biometric_present.impression_id).personnel.name]
								end

								present.uniq!
								remote_present.uniq!

								message+=" *In Office/Site* \n"
								present.each do |employee_name|
									message+=(employee_name)+"\n"
								end

								message+="\n*Remote* \n"
								remote_present.each do |employee_name|
									message+=(employee_name)+"\n"
								end
							elsif 'collection'.include? (body.gsub(/\s+/, '').downcase)
								month=Time.now.month
								year=Time.now.year
								last_date=Date.civil(year, month, -1)
								request_params = {:period => last_date}
								urlstring="http://115.243.56.197:70/window/collection.json?#{request_params.to_query}"
								collection_response=HTTParty.get(urlstring)
								total=0
								collection_response.each do |data|
								    message+=data["PROJECT"]+"- *"
								    message+=comma_separated(data[""].to_i)+"* ("
								    total+=(data[""].to_i)
								    request_params = {:project => data["PROJECT"]}
								    urlstring =  "https://postcrm.herokuapp.com/window/outstanding_api.json?#{request_params.to_query}"
								    result = HTTParty.get(urlstring)
								    message+=(comma_separated(result['amount']))+")\n\n"
								end
								message='TOTAL - *'+ comma_separated(total)	+"* \n\n" +message
							elsif 'collection-1'.include? (body.gsub(/\s+/, '').downcase)
								month=Time.now.month
								year=Time.now.year
								last_date=Date.civil(year, month-1, -1)
								request_params = {:period => last_date}
								urlstring="http://115.243.56.197:70/window/collection.json?#{request_params.to_query}"
								collection_response=HTTParty.get(urlstring)
								total=0
								collection_response.each do |data|
								    message+=data["PROJECT"]+"- *"
								    message+=comma_separated(data[""].to_i)+"* ("
								    total+=(data[""].to_i)
								    request_params = {:project => data["PROJECT"]}
								    urlstring =  "https://postcrm.herokuapp.com/window/outstanding_api.json?#{request_params.to_query}"
								    result = HTTParty.get(urlstring)
								    message+=(comma_separated(result['amount']))+")\n\n"
								end
								message='TOTAL - *'+ comma_separated(total)	+"* \n\n" +message
							elsif 'collection-2'.include? (body.gsub(/\s+/, '').downcase)
								month=Time.now.month
								year=Time.now.year
								last_date=Date.civil(year, month-2, -1)
								request_params = {:period => last_date}
								urlstring="http://115.243.56.197:70/window/collection.json?#{request_params.to_query}"
								collection_response=HTTParty.get(urlstring)
								total=0
								collection_response.each do |data|
								    message+=data["PROJECT"]+"- *"
								    message+=comma_separated(data[""].to_i)+"* ("
								    total+=(data[""].to_i)
								    request_params = {:project => data["PROJECT"]}
								    urlstring =  "https://postcrm.herokuapp.com/window/outstanding_api.json?#{request_params.to_query}"
								    result = HTTParty.get(urlstring)
								    message+=(comma_separated(result['amount']))+")\n\n"
								end
								message='TOTAL - *'+ comma_separated(total)	+"* \n\n" +message
							elsif 'collection-3'.include? (body.gsub(/\s+/, '').downcase)
								month=Time.now.month
								year=Time.now.year
								last_date=Date.civil(year, month-3, -1)
								request_params = {:period => last_date}
								urlstring="http://115.243.56.197:70/window/collection.json?#{request_params.to_query}"
								collection_response=HTTParty.get(urlstring)
								total=0
								collection_response.each do |data|
								    message+=data["PROJECT"]+"- *"
								    message+=comma_separated(data[""].to_i)+"* ("
								    total+=(data[""].to_i)
								    request_params = {:project => data["PROJECT"]}
								    urlstring =  "https://postcrm.herokuapp.com/window/outstanding_api.json?#{request_params.to_query}"
								    result = HTTParty.get(urlstring)
								    message+=(comma_separated(result['amount']))+")\n\n"
								end
								message='TOTAL - *'+ comma_separated(total)	+"* \n\n" +message
							elsif 'outstanding'.include? (body.gsub(/\s+/, '').downcase)
								projects=['DREAM ONE BLK 1 \ 2','DREAM ONE BLK 3 \ 4','DREAM GATEWAY PAILAN PROJECTS','DREAM JAIN-PAILAN','DREAM VALLEY','DREAM ECOCITY','DREAM EXOTICA','DREAM RESIDENCY MANOR','DREAM PALAZZO','DREAM PRATHAM']	
								total=0
								projects.each do |data|
								    message+=data+"-"
								    
								    request_params = {:project => data}
								    urlstring =  "https://postcrm.herokuapp.com/window/outstanding_api.json?#{request_params.to_query}"
								    result = HTTParty.get(urlstring)
								    total+=(result['amount'].to_i)
								    message+=(comma_separated(result['amount']))+"\n\n"

								end
								message='TOTAL - *'+ comma_separated(total)	+"* \n\n" +message
							elsif 'topoutstanding'.include? (body.gsub(/\s+/, '').downcase)
								message+="Use Top Outsanding followed by Serial No. of project from the following list(eg topoutstanding1): \n\n0. All\n"
								projects=['DREAM ONE BLK 1 \ 2','DREAM ONE BLK 3 \ 4','DREAM GATEWAY PAILAN PROJECTS','DREAM JAIN-PAILAN','DREAM VALLEY','DREAM ECOCITY']	
								projects.each_with_index do |project, serial|
								message+=((serial+1).to_s)+'. '+project+"\n"	
								end
							elsif outstanding_projects.select{|video_link| video_link[0].include? (body.gsub(/\s+/, '').downcase)} != []
								outstanding_project=outstanding_projects.select{|video_link| video_link[0].include? (body.gsub(/\s+/, '').downcase)}			
								message+=outstanding_project[0].try{|x| x[1]}
							elsif vendors.select{|vendor| vendor[0].include? (body.gsub(/\s+/, '').downcase)} != []
								vendor_selected=vendors.select{|vendor| vendor[0].include? (body.gsub(/\s+/, '').downcase)}			
								vendor=vendor_selected[0].try{|x| x[1]}
								request_params = {:vendor => vendor}
								urlstring="http://115.243.56.197:70/window/creditor_ledger_details.json?#{request_params.to_query}"
								@ledger_details=HTTParty.get(urlstring)
								@ledger_details.sort_by!{|x| x['ACTUAL_DATE']}

									  	@ledger_pdf=render_to_string(:partial => "ledger_convert.html.erb", :layout => false, :locals => { :ledger_details => @ledger_details})
										@ledger_pdf='<html><body>'+@ledger_pdf+'</body></html>'
										@pdf = WickedPdf.new.pdf_from_string(@ledger_pdf)
									  	@pdf=Base64.encode64(@pdf) 
									  	@pdf='data:application/pdf;base64,'+@pdf
									  	
										urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							  			result = HTTParty.get(urlstring,
									   	:body => { :phone => mobile,
									              :body => @pdf,
									              :filename => vendor+' ledger.pdf' 
									              }.to_json,
									   :headers => { 'Content-Type' => 'application/json' } )

								message+='Vendor: ' + vendor_selected[0].try{|x| x[1]}
							# elsif ['918420541541','919007320320', '919007576657', '916289142885'].include? mobile
							# 	if from_me==true
							# 	else
							# 		if body.index('The Jain Group') != nil
							# 		name_stop=body.index(',')
							# 				if name_stop != nil
							# 				customer_name=body[13..(name_stop-1)]
							# 				request_params = {:applicant => customer_name}
							# 				outstanding_urlstring="http://115.243.56.197:70/window/customer_outstanding.json?#{request_params.to_query}"
							# 				outstanding_response=HTTParty.get(outstanding_urlstring)
							# 				total_demand_raised=0
							# 				total_payment_made=0
							# 				total_outstanding=0
							# 				total_on_ac=0
							# 					outstanding_response.each do |data|
							# 					total_demand_raised+=(data["BILLAMT"].to_i)
							# 					total_payment_made+=(data["PAIDAMT"].to_i)
							# 					total_on_ac+=(data["ONACAMT"].to_i)
							# 					total_outstanding+=(data["DUEAMT"].to_i)
							# 					end
							# 				message+="*TOTAL DEMAND RAISED("+(comma_separated(total_demand_raised).to_s)+")*\n\n"
							# 				message+="*TOTAL PAYMENT MADE TILL NOW("+(comma_separated(total_payment_made+total_on_ac).to_s)+")*\n\n"
							# 				message+="*OUTSTANDING("+(comma_separated(total_outstanding-total_on_ac).to_s)+")*\n\n"
							# 				urlstring="http://115.243.56.197:70/window/customer_collection.json?#{request_params.to_query}"
							# 				collection_response=HTTParty.get(urlstring)
							# 				total_collection=0
							# 				total_cheque_reversal=0
							# 					collection_response.each do |data|
							# 					total_collection+=(data["AMOUNT"].to_i)
							# 					total_cheque_reversal+=(data["CEHQUE REVERSAL"].to_i)
							# 					end
							# 					net_collection=total_collection-total_cheque_reversal
							# 				message+="*PAYMENT DETAILS("+(comma_separated(net_collection).to_s)+")*\n\n"
												
							# 					collection_response.each do |data|
							# 					    if data["CEHQUE REVERSAL"].to_i > 0
							# 					    message+=data["CHQDT"]	
							# 					    message+=' - '
							# 						message+=(comma_separated(data["AMOUNT"].to_i).to_s)+"-reversed"+"\n"
							# 					    else
							# 					    message+=data["CHQDT"]	
							# 					    message+=' - '
							# 						message+=(comma_separated(data["AMOUNT"].to_i).to_s)+"\n"
							# 						end
							# 					end
							# 			   end
							# 		end
							# 	end	
							elsif 'projectwiseleadreport'.include? (body.gsub(/\s+/, '').downcase)
								p 'pwr check'
								urlstring="http://dreamcrm.herokuapp.com/windows/mis_genie.json"
								mis_response=HTTParty.get(urlstring)
								mis_response['project_wise_this_months_count'].each_with_index do |this_months_count, serial|
									message+="*"+this_months_count[0] + "*:\n\n"

									message+="*_CurrentMonth(6MonthAvg):_*\n"
									message+="Leads - *"+this_months_count[1].to_s+"*("+((mis_response['project_wise_last_6_months_count'][serial][1].to_i/6).to_s)+")"+"\n"
									message+="SiteVisits - *"+this_months_count[2].to_s+"*("+((mis_response['project_wise_last_6_months_count'][serial][2].to_i/6).to_s)+")"+"\n"
									message+="Bookings - *"+this_months_count[5].to_s+"*("+((mis_response['project_wise_last_6_months_count'][serial][5].to_i/6).to_s)+")"+"\n"
									
									message+="\n*_6MonthTrend:_*\n"
									message+="Leads-"+mis_response['project_wise_six_month_before_count'][serial][3].to_s+','+mis_response['project_wise_five_month_before_count'][serial][3].to_s+','+mis_response['project_wise_four_month_before_count'][serial][3].to_s+','+mis_response['project_wise_three_month_before_count'][serial][3].to_s+','+mis_response['project_wise_two_month_before_count'][serial][3].to_s+','+mis_response['project_wise_one_month_before_count'][serial][3].to_s+"\n"
									message+="SiteVisits-"+mis_response['project_wise_six_month_before_count'][serial][4].to_s+','+mis_response['project_wise_five_month_before_count'][serial][4].to_s+','+mis_response['project_wise_four_month_before_count'][serial][4].to_s+','+mis_response['project_wise_three_month_before_count'][serial][4].to_s+','+mis_response['project_wise_two_month_before_count'][serial][4].to_s+','+mis_response['project_wise_one_month_before_count'][serial][4].to_s+"\n"
									message+="Bookings-"+mis_response['project_wise_six_month_before_count'][serial][5].to_s+','+mis_response['project_wise_five_month_before_count'][serial][5].to_s+','+mis_response['project_wise_four_month_before_count'][serial][5].to_s+','+mis_response['project_wise_three_month_before_count'][serial][5].to_s+','+mis_response['project_wise_two_month_before_count'][serial][5].to_s+','+mis_response['project_wise_one_month_before_count'][serial][5].to_s+"\n\n\n"
									
								end
							elsif 'executivewiseleadreport'.include? (body.gsub(/\s+/, '').downcase)
								urlstring="http://dreamcrm.herokuapp.com/windows/executive_wise_mis_genie.json"
								mis_response=HTTParty.get(urlstring)
								mis_response['executive_wise_this_months_count'].each_with_index do |this_months_count, serial|
									message+="*"+this_months_count[0] + "*:\n\n"

									message+="*_CurrentMonth(6MonthAvg):_*\n"
									message+="Leads - *"+this_months_count[1].to_s+"*("+((mis_response['executive_wise_last_6_months_count'][serial][1].to_i/6).to_s)+")"+"\n"
									message+="SiteVisits - *"+this_months_count[2].to_s+"*("+((mis_response['executive_wise_last_6_months_count'][serial][2].to_i/6).to_s)+")"+"\n"
									message+="Bookings - *"+this_months_count[5].to_s+"*("+((mis_response['executive_wise_last_6_months_count'][serial][5].to_i/6).to_s)+")"+"\n"
									
									message+="\n*_6MonthTrend:_*\n"
									message+="Leads-"+mis_response['executive_wise_six_month_before_count'][serial][3].to_s+','+mis_response['executive_wise_five_month_before_count'][serial][3].to_s+','+mis_response['executive_wise_four_month_before_count'][serial][3].to_s+','+mis_response['executive_wise_three_month_before_count'][serial][3].to_s+','+mis_response['executive_wise_two_month_before_count'][serial][3].to_s+','+mis_response['executive_wise_one_month_before_count'][serial][3].to_s+"\n"
									message+="SiteVisits-"+mis_response['executive_wise_six_month_before_count'][serial][4].to_s+','+mis_response['executive_wise_five_month_before_count'][serial][4].to_s+','+mis_response['executive_wise_four_month_before_count'][serial][4].to_s+','+mis_response['executive_wise_three_month_before_count'][serial][4].to_s+','+mis_response['executive_wise_two_month_before_count'][serial][4].to_s+','+mis_response['executive_wise_one_month_before_count'][serial][4].to_s+"\n"
									message+="Bookings-"+mis_response['executive_wise_six_month_before_count'][serial][5].to_s+','+mis_response['executive_wise_five_month_before_count'][serial][5].to_s+','+mis_response['executive_wise_four_month_before_count'][serial][5].to_s+','+mis_response['executive_wise_three_month_before_count'][serial][5].to_s+','+mis_response['executive_wise_two_month_before_count'][serial][5].to_s+','+mis_response['executive_wise_one_month_before_count'][serial][5].to_s+"\n\n\n"
									
								end
							elsif 'startdelayed'.include? (body.gsub(/\s+/, '').downcase)
								require 'watir-screenshot-stitch'
								require 'webdrivers'
								require 'faker'
								Selenium::WebDriver::Chrome.path = "/app/.apt/usr/bin/google-chrome"
							    Selenium::WebDriver::Chrome.driver_path = "/app/.chromedriver/bin/chromedriver"

								browser = Watir::Browser.new :chrome, headless: true
								browser.goto 'www.projectinhand.com'
								browser.text_field(id: 'inputEmail').set 'vc@thejaingroup.com'
								browser.text_field(id: 'inputPassword').set 'vc12345'
								browser.button(name: 'commit').click
								browser.link(:text =>"Graphical Report").wait_until_present.click
								browser.button(text: 'Start Delayed').click
								

										  	pictorial_progress='data:image/png;base64,'+(browser.screenshot.base64_canvas)
										  	
											urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
								  			result = HTTParty.get(urlstring,
										   	:body => { :phone => mobile,
										              :body => pictorial_progress,
										              :filename => 'Pictorial Progress.png' 
										              }.to_json,
										   :headers => { 'Content-Type' => 'application/json' } )
								
							elsif 'finishdelayed'.include? (body.gsub(/\s+/, '').downcase)
								urlstring =  "http://inranger.herokuapp.com/transactions/finish_delay?mobile="+mobile
								result = HTTParty.get(urlstring)				   	
							elsif 'ongoing'.include? (body.gsub(/\s+/, '').downcase)
							elsif 'upcoming'.include? (body.gsub(/\s+/, '').downcase)		
							elsif 'critical'.include? (body.gsub(/\s+/, '').downcase)
							elsif 'activitylist'.include? (body.gsub(/\s+/, '').downcase)
							elsif 'contractorlist'.include? (body.gsub(/\s+/, '').downcase)
							elsif 'itemlist'.include? (body.gsub(/\s+/, '').downcase)	
							elsif 'pipeline'.include? (body.gsub(/\s+/, '').downcase)
								urlstring="http://dreamcrm.herokuapp.com/windows/personnel_wise_leads_genie.json"
								pipeline_response=HTTParty.get(urlstring)
								grand_total_leads=0
								total_fresh_leads=0
								total_follow_ups_due=0
								total_future_follow_ups=0
								total_site_visited_follow_ups=0

								pipeline_response['total_leads'].each do |personnel, total_leads|
								grand_total_leads+=total_leads
								total_fresh_leads+=(pipeline_response['fresh_leads'][personnel].to_i)
								total_follow_ups_due+=(pipeline_response['follow_ups_due'][personnel].to_i)
								total_future_follow_ups+=(pipeline_response['future_follow_ups'][personnel].to_i)
								total_site_visited_follow_ups+=(pipeline_response['future_follow_ups_site_visited'][personnel].to_i+pipeline_response['follow_ups_due_site_visited'][personnel].to_i)
								end

									message+="*"+"TOTAL" + "*:\n"
								    message+="Fresh Leads-"+ (total_fresh_leads.to_s)+"\n"
								    message+="Followups Due-"+ (total_follow_ups_due.to_s)+"\n"
								    message+="Future Followups-"+ (total_future_follow_ups.to_s)+"\n"
								    message+="*_All-"+ (grand_total_leads.to_s)+"_*\n"
								    message+="_Site Visited Followups-"+ (total_site_visited_follow_ups.to_s)+"_\n\n"

								pipeline_response['total_leads'].each do |personnel, total_leads|
								    message+="*"+personnel + "*:\n"
								    message+="Fresh Leads-"+ (pipeline_response['fresh_leads'][personnel].to_i.to_s)+"\n"
								    message+="Followups Due-"+ (pipeline_response['follow_ups_due'][personnel].to_i.to_s)+"\n"
								    message+="Future Followups-"+ (pipeline_response['future_follow_ups'][personnel].to_i.to_s)+"\n"
								    message+="*_Total-"+ total_leads.to_s+"_*\n"
								    message+="_Site Visited Followups-"+ ((pipeline_response['future_follow_ups_site_visited'][personnel].to_i+pipeline_response['follow_ups_due_site_visited'][personnel].to_i).to_s)+"_\n\n"
								end
							end
							if message != ''	
							urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
								  		result = HTTParty.get(urlstring,
										   :body => { :phone => mobile,
										              :body => message 
										              }.to_json,
										   :headers => { 'Content-Type' => 'application/json' } )
							else
								p '2329 null message'
							end			

				else
							mobile_check=mobile
							urlstring =  "https://www.realtybucket.com/webhook/check_lead_existence?mobile="+mobile_check
				            lead_check_result = HTTParty.get(urlstring)
				            message=''
				            # need lead_id, leads business unit
							if lead_check_result.parsed_response != 'false'
								dash_index=lead_check_result.parsed_response.index('-')
								hash_index=lead_check_result.parsed_response.index('#')
								project_for_bot=lead_check_result.parsed_response[0..(dash_index-1)]
								bot_lead_id=lead_check_result.parsed_response[(dash_index+1)..(hash_index-1)]
								expert_number=lead_check_result.parsed_response[(hash_index+1)..(lead_check_result.parsed_response.length-1)]
								if project_for_bot=='Dream One'
									brochure_url='https://drive.google.com/uc?id=1NpO0HyRHage-SXOTUbAkdgaLFy2KUVmL&export=download'
									plan_url='https://drive.google.com/uc?id=1NpO0HyRHage-SXOTUbAkdgaLFy2KUVmL&export=download'
									photo_url='https://dreamone.co.in/#views'
									location_link='https://goo.gl/maps/Mb9FpeFDKf8xYUxF8'
									address="AA II, Newtown, New Town, West Bengal 700156"
									position_1 = lead_check_result.parsed_response.index("#")
									location_text="Timing - 10 AM to 6 PM.\n\nFor Direction Call "+expert_number
									walkthrough_url='https://youtu.be/176G3unxtuI'
									about_us_url='https://dreamone.co.in/#about'
									# expert_number='7044222888'
								elsif project_for_bot=='Dream One Hotel Apartment'
									brochure_url="https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21522&authkey=AFju84UXVqFOOSA&em=2"
									plan_url="https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21522&authkey=AFju84UXVqFOOSA&em=2"
									photo_url='http://www.dreamonehotel.com/#views'
									location_link='https://goo.gl/maps/Mb9FpeFDKf8xYUxF8'
									address="AA II, Newtown, New Town, West Bengal 700156"
									position_1 = lead_check_result.parsed_response.index("#")
									location_text="Timing - 10 AM to 6 PM.\n\nFor Direction Call "+expert_number
									walkthrough_url='https://youtu.be/176G3unxtuI'
									about_us_url='http://www.dreamonehotel.com/#about'
									# expert_number='7044222888'
								elsif project_for_bot=='Dream World City'
									ongoing_rate='3700/-'
									project_summary='https://drive.google.com/uc?id=1d626bjxgKMlXIO5nll1FEZVZnpWlgHJN&export=download'
									brochure_url='https://drive.google.com/uc?id=1kplEZa_XYq20EXPBlAc8GbiDPRqtpGse&export=download'
									brochure_url_2='https://drive.google.com/uc?1CUtK_bPQPLyq-W9ujsYEajelXx7kIQ83&export=download'
									plan_url='https://drive.google.com/uc?id=1kplEZa_XYq20EXPBlAc8GbiDPRqtpGse&export=download'
									photo_url="https://dreamworldcity.in/#gallery"
									location_link='https://goo.gl/maps/L5u4DG3wjFYurKmv5'
									address="Kalitala, Nepalgunj, Road, Pailan, Kolkata, West Bengal 700104"
									position_1 = lead_check_result.parsed_response.index("#")
									location_text="Near Joka metro, beside Pailan International school\n\nTiming - 10 AM to 6 PM.\n\nFor Direction Call "+expert_number
									walkthrough_url='https://youtu.be/UOkr2c-P3PY'
									about_us_url='https://www.thejaingroup.com/our-story.php'
									# expert_number='9903036669'
								elsif project_for_bot=='Dream Valley'
									brochure_url='https://onedrive.live.com/download?cid=D59E6686F5173A0F&resid=D59E6686F5173A0F%21132&authkey=ALjwi9zsaAOTxOs&em=2'
									plan_url='https://onedrive.live.com/download?cid=D59E6686F5173A0F&resid=D59E6686F5173A0F%21132&authkey=ALjwi9zsaAOTxOs&em=2'
									photo_url='https://dreamvalley.net.in/#views'
									location_link='https://goo.gl/maps/RKMv4u6Fin74zDXP7'
									address='Hill Cart Rd, Dagapur, Daknikata P, West Bengal 734001, India'
									position_1 = lead_check_result.parsed_response.index("#")
									location_text= "Timing - 9 AM to 6 PM.\n\nFor Direction Call "+expert_number
									walkthrough_url='https://youtu.be/i5pZCcHlmk0'
									about_us_url='https://dreamvalley.net.in/index.php#about'
								elsif project_for_bot=='Dream Eco City'
									brochure_url='https://onedrive.live.com/download?cid=D59E6686F5173A0F&resid=D59E6686F5173A0F%21130&authkey=AH2Vkfy3lmoxzFY&em=2'
									plan_url='https://onedrive.live.com/download?cid=D59E6686F5173A0F&resid=D59E6686F5173A0F%21130&authkey=AH2Vkfy3lmoxzFY&em=2'
									photo_url='https://dreamecocity.com/#flat-tour'
									location_link='https://goo.gl/maps/iBLU5io4khLVgTVG7'
									address='G926+7P8, Muchipara Market, Durgapur'
									position_1 = lead_check_result.parsed_response.index("#")
									location_text="Timing - 10 AM to 6 PM.\n\nFor Direction Call "+expert_number
									walkthrough_url='https://youtu.be/kZ28tpjb9Ug'
									about_us_url='https://dreamecocity.com/index.php#about'
								end
									
								if from_me != true
									if body.gsub(/\s+/, '').downcase=='hi'
										message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
									elsif body.gsub(/\s+/, '').downcase=='hello'
										message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
									elsif body.gsub(/\s+/, '').downcase=='hii'
										message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
									elsif body.gsub(/\s+/, '').downcase=='hey'
										message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
									elsif body.gsub(/\s+/, '').downcase=='hye'
										message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
									elsif body.gsub(/\s+/, '').downcase.include? 'morn'
										message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
									elsif body.gsub(/\s+/, '').downcase.include? 'noon'
										message="Hi,\n\nWhatsapp any of the above keywords or serial numbers, to help us provide you with correct information."
									elsif body.gsub(/\s+/, '').downcase.include? 'thank'
										message="You are most welcome🙏\n\nRegards,\nJain Group\n"+expert_number
									elsif body.gsub(/\s+/, '').downcase.include? 'thx'
										message="You are most welcome🙏\n\nRegards,\nJain Group\n"+expert_number
									elsif body.gsub(/\s+/, '').downcase=='okay' || body.gsub(/\s+/, '').downcase=='ok' || body.gsub(/\s+/, '').downcase=='ohk' || body.gsub(/\s+/, '').downcase=='k' || body.gsub(/\s+/, '').downcase=='okk'
										message="Thank you for your valuable time🙏\n\nRegards,\nJain Group\n"+expert_number
									elsif body.gsub(/\s+/, '').downcase.include? 'notinterested'
										message="Thank you for your valuable time🙏\n\nRegards,\nJain Group"
									elsif body.gsub(/\s+/, '').downcase=="👍" || body.gsub(/\s+/, '').downcase=="👍🏽"|| body.gsub(/\s+/, '').downcase=="👍🏻" || body.gsub(/\s+/, '').downcase=="nice" ||  body.gsub(/\s+/, '').downcase=="cool" || body.gsub(/\s+/, '').downcase=="vow" || body.gsub(/\s+/, '').downcase=="welcome" || body.gsub(/\s+/, '').downcase=="wlcm"
										message='Anytime 😎'
									elsif body.gsub(/\s+/, '').downcase=='yes'
										message="ok"
									end

									if project_for_bot=='Dream Elite'
										if body=='YES 😊'
											past_customer_option='Yes he is happy'
											urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
												  		result = HTTParty.get(urlstring,
														   :body => { :phone => mobile,
														              :body => "*Please recommend us to your friends and family🙏*\n\nKindly share contact(s) by attaching 📎 and sending ▶️ \n\nRegards,\nJain Group\n"+expert_number 
														              }.to_json,
														   :headers => { 'Content-Type' => 'application/json' } )
										elsif body=='NO ☹️'
											past_customer_option='No he is not happy'	
											urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
											    result = HTTParty.get(urlstring,
											            :body => { :phone => mobile,
											            		  :body => 'Which area are you having issues with?',
											                      :buttons => ['Post Sales/Customer Service','Operations/Site Team','Maintenance']
											                      }.to_json,
											           :headers => { 'Content-Type' => 'application/json' } )
										elsif body=='Post Sales/Customer Service' || body=='Operations/Site Team' || body=='Maintenance'
											past_customer_option='Customer has an issue with '+body
											urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
											    result = HTTParty.get(urlstring,
											            :body => { :phone => mobile,
											            		  :body => 'Kindly choose from the following:',
											                      :buttons => ['Speak to Director','Describe Issue in Detail']
											                      }.to_json,
											           :headers => { 'Content-Type' => 'application/json' } )
										elsif body=='Speak to Director'
											past_customer_option='Customer wants to speak to the Director'
											urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
												  		result = HTTParty.get(urlstring,
														   :body => { :phone => mobile,
														              :body => "*We are getting it arranged, thank you for your feedback🙏*\n\nJain Group\n"+expert_number 
														              }.to_json,
														   :headers => { 'Content-Type' => 'application/json' } )
										elsif body=='Describe Issue in Detail'
											past_customer_option='Customer wants to describe issue in detail'
											urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
												  		result = HTTParty.get(urlstring,
														   :body => { :phone => mobile,
														              :body => "Details of the inconvenience faced can be either shared by typing or sending a voice by pressing the mic icon🙏\n\nJain Group\n"+expert_number 
														              }.to_json,
														   :headers => { 'Content-Type' => 'application/json' } )
										end

									end

									if body=='Joka 3%'
										p 'within joka'
											channel_partner_option='Joka chosen'
											urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
			  				                result = HTTParty.get(urlstring,
			  				                        :body => { :phone => mobile,
			  				                                  :body => "https://drive.google.com/uc?id=1d626bjxgKMlXIO5nll1FEZVZnpWlgHJN&export=download",
			  				                                  :filename => 'project_summary.pdf'  
			  				                                  }.to_json,
			  				                       :headers => { 'Content-Type' => 'application/json' } )
											urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
												  		result = HTTParty.get(urlstring,
														   :body => { :phone => '91'+expert_number,
														              :body => 'Joka chosen, please call and confirm: '+(mobile) 
														              }.to_json,
														   :headers => { 'Content-Type' => 'application/json' } )	  		
										
											urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
										    result = HTTParty.get(urlstring,
										            :body => { :phone => mobile,
										            		  :body => 'To move ahead:',
										                      :buttons => ['Request a Call Back','Want more Details','Not Interested']
										                      }.to_json,
										           :headers => { 'Content-Type' => 'application/json' } )	  		
										@urlstring='http://www.realtybucket.com/webhook/qualify_lead'
										HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
									elsif body=='Rajarhat 3%'
										channel_partner_option='Rajarhat chosen'
										urlstring = "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
						                  result = HTTParty.get(urlstring,
						                          :body => { :phone => mobile,
						                                    :body => "https://drive.google.com/uc?id=1NpO0HyRHage-SXOTUbAkdgaLFy2KUVmL&export=download",
						                                    :filename => 'brochure.pdf'  
							                                    }.to_json,
						                         :headers => { 'Content-Type' => 'application/json' } )
						                  urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
									  		result = HTTParty.get(urlstring,
											   :body => { :phone => '91'+expert_number,
											              :body => 'Rajarhat chosen, please call and confirm: '+(mobile) 
											              }.to_json,
											   :headers => { 'Content-Type' => 'application/json' } )
									  	urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
										    result = HTTParty.get(urlstring,
										            :body => { :phone => mobile,
										            		  :body => 'To move ahead:',
										                      :buttons => ['Request a Call Back','Want more Details','Not Interested']
										                      }.to_json,
										           :headers => { 'Content-Type' => 'application/json' } )	
										@urlstring='http://www.realtybucket.com/webhook/qualify_lead'
										HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
									elsif body=='Outstation 3%'
										channel_partner_option='Rajarhat chosen'
										urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
									    result = HTTParty.get(urlstring,
									            :body => { :phone => mobile,
									            		  :body => 'Kindly choose from the following:',
									                      :buttons => ['Siliguri-Dream Valley','Durgapur-Dream Eco City','Not Interested']
									                      }.to_json,
									           :headers => { 'Content-Type' => 'application/json' } )

										urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
									  		result = HTTParty.get(urlstring,
											   :body => { :phone => '91'+expert_number,
											              :body => 'Outstation chosen, please call and confirm: '+(mobile) 
											              }.to_json,
											   :headers => { 'Content-Type' => 'application/json' } )

									elsif body=='Durgapur-Dream Eco City'
										channel_partner_option='Eco City chosen'
										urlstring = "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
						                  result = HTTParty.get(urlstring,
						                          :body => { :phone => mobile,
						                                    :body => "https://onedrive.live.com/download?cid=3F3CF1D351D4BABC&resid=3F3CF1D351D4BABC%21265&authkey=ANLQwr5bB1vd60w&em=2",
						                                    :filename => 'Project Summary.pdf'  
							                                    }.to_json,
						                         :headers => { 'Content-Type' => 'application/json' } )
						                  urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
									  		result = HTTParty.get(urlstring,
											   :body => { :phone => '91'+expert_number,
											              :body => 'Eco City chosen, please call and confirm: '+(mobile) 
											              }.to_json,
											   :headers => { 'Content-Type' => 'application/json' } )
									  	urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
										    result = HTTParty.get(urlstring,
										            :body => { :phone => mobile,
										            		  :body => 'To move ahead:',
										                      :buttons => ['Request a Call Back','Want more Details','Not Interested']
										                      }.to_json,
										           :headers => { 'Content-Type' => 'application/json' } )	
										@urlstring='http://www.realtybucket.com/webhook/qualify_lead'
										HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
									elsif body=='Siliguri-Dream Valley'
									channel_partner_option='Valley chosen'
										urlstring = "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
						                  result = HTTParty.get(urlstring,
						                          :body => { :phone => mobile,
						                                    :body => "https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21496&authkey=AJrVb9ATW3t3liQ&em=2",
						                                    :filename => 'Brochure.pdf'  
							                                    }.to_json,
						                         :headers => { 'Content-Type' => 'application/json' } )
						                  urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
									  		result = HTTParty.get(urlstring,
											   :body => { :phone => '91'+expert_number,
											              :body => 'Valley chosen, please call and confirm: '+(mobile) 
											              }.to_json,
											   :headers => { 'Content-Type' => 'application/json' } )
									  	urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
										    result = HTTParty.get(urlstring,
										            :body => { :phone => mobile,
										            		  :body => 'To move ahead:',
										                      :buttons => ['Request a Call Back','Want more Details','Not Interested']
										                      }.to_json,
										           :headers => { 'Content-Type' => 'application/json' } )	
										@urlstring='http://www.realtybucket.com/webhook/qualify_lead'
										HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
									elsif body=='Request a Call Back'
										channel_partner_option='Call back requested'
										message="Thank you for your time, we will get in touch with you shortly!\n\nRegards,\nJain Group\n"+expert_number
										urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											  		result = HTTParty.get(urlstring,
													   :body => { :phone => mobile,
													              :body => message 
													              }.to_json,
													   :headers => { 'Content-Type' => 'application/json' } )
										urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
									  		result = HTTParty.get(urlstring,
											   :body => { :phone => '91'+expert_number,
											              :body => 'Channel partner requested a call back, please call and confirm: '+(mobile) 
											              }.to_json,
											   :headers => { 'Content-Type' => 'application/json' } )	  		
										@urlstring='http://www.realtybucket.com/webhook/isv_lead'
										HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
									elsif body=='Want more Details'
										channel_partner_option='Needs more detail'
										message="We will be sending you more details shortly and also call you for further assistance.\n\nRegards,\nJain Group\n"+expert_number
										urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											  		result = HTTParty.get(urlstring,
													   :body => { :phone => mobile,
													              :body => message 
													              }.to_json,
													   :headers => { 'Content-Type' => 'application/json' } )
										urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
									  		result = HTTParty.get(urlstring,
											   :body => { :phone => '91'+expert_number,
											              :body => 'Channel partner requested more details, please call and confirm: '+(mobile) 
											              }.to_json,
											   :headers => { 'Content-Type' => 'application/json' } )	  		
										@urlstring='http://www.realtybucket.com/webhook/isv_lead'
										HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
									end

									if body=='2BHK' || body=='3BHK' || body=='4BHK' || body=='5BHK' || body=='Penthouse'
										bhk_option=true
										message="Thank you for contacting Jain Group, our sales expert will get in touch with you shortly!\n\nRegards,\nJain Group\n"+expert_number
										urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											  		result = HTTParty.get(urlstring,
													   :body => { :phone => mobile,
													              :body => message 
													              }.to_json,
													   :headers => { 'Content-Type' => 'application/json' } )
										urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											  		result = HTTParty.get(urlstring,
													   :body => { :phone => '91'+expert_number,
													              :body => 'Customer chose BHK preference, please call and confirm: '+(mobile) 
													              }.to_json,
													   :headers => { 'Content-Type' => 'application/json' } )	  		
									@urlstring='http://www.realtybucket.com/webhook/qualify_lead'
									HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})    
									end

									if bhk_option==true
									elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?(':')
									  	message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJain Group\n"+expert_number
									elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('-')
										message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJain Group\n"+expert_number
									elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('am')
										message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJain Group\n"+expert_number
									elsif body.gsub(/\s+/, '').downcase.include?('/') && body.gsub(/\s+/, '').downcase.include?('pm')
										message="Thank you, your appointment has been duly noted🙏\n\nWe appreciate your interest in our project.\n\nInvesting in an apartment is a major life decision and we are happy to be able to help you make the right choice.\n\nOur executive will get in touch with you shortly to coordinate the visit.\n\nRegards,\nJain Group\n"+expert_number
									else
										p 'in number series'
									  number_series=body.downcase.gsub(/\s+/, '').gsub(',', '').gsub(')', '').gsub(';', '').gsub('and', '').gsub('&', '').gsub('.', '').gsub('nos', '').gsub('no', '').gsub('sl', '').gsub('/', '').gsub('send', '').gsub('n', '').gsub('to', '').gsub('-', '')

									  	  if number_series.length>1
										  	if number_series[0].to_i != 0 || number_series.reverse[0].to_i != 0
										  		number_length=number_series.length
										  		if number_series.reverse[0].to_i != 0 && number_series[0].to_i == 0
										  			number_series=number_series.reverse
										  		end
										  		number_length.times do |position|
										  			if project_for_bot=='Dream World City'
							  							if number_series[position].to_i == 0
											  				message=''
											  				break
											  			elsif number_series[position]=='1'
							  								message='👇 Project Summary being sent please wait...'
							  								
		  													urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => "+91"+mobile,
		  								                 	:message => project_summary,
		  								                 	:text => "",    
		  								                  	:type => "media"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


							  								# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							  				    #             result = HTTParty.get(urlstring,
							  				    #                     :body => { :phone => mobile,
							  				    #                               :body => project_summary,
							  				    #                               :filename => 'project_summary.pdf'  
							  				    #                               }.to_json,
							  				    #                    :headers => { 'Content-Type' => 'application/json' } )
							  							elsif number_series[position]=='2'
							  								message=ongoing_rate	
							  							elsif number_series[position]=='3'
							  								message=possession_date	
							  							elsif number_series[position]=='4'
							  								
		  													urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => "+91"+mobile,
		  								                 	:message => location_link,
		  								                 	:type => "text"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


		  								            		urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => "+91"+mobile,
		  								                 	:message => address,
		  								                 	:type => "text"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

							  								# urlstring =  "https://eu71.chat-api.com/instance124988/sendLink?token=awjkvkwi2sdzv65j"
							  				    #             result = HTTParty.get(urlstring,
							  				    #                     :body => { :phone => mobile,
							  				    #                               :body => location_link,
							  				    #                               :title => project_for_bot,
							  				    #                               :description => address  
							  				    #                               }.to_json,
							  				    #                    :headers => { 'Content-Type' => 'application/json' } )
							  				                message=location_text
							  							elsif number_series[position]=='5'
							  								message='👇 Brochure being sent please wait...'
							  								
		  													urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => "+91"+mobile,
		  								                 	:message => brochure_url,
		  								                 	:text =>  "",
		  								                 	:type => "media"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


							  								# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							  				    #             result = HTTParty.get(urlstring,
							  				    #                     :body => { :phone => mobile,
							  				    #                               :body => brochure_url,
							  				    #                               :filename => 'brochure.pdf'  
							  				    #                               }.to_json,
							  				    #                    :headers => { 'Content-Type' => 'application/json' } )
							  				                
							  				                if brochure_url_2 != nil
							  				                
		  				                					urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  				                            		@result = HTTParty.post(urlstring,
		  				                               		:body => { :to_number => "+91"+mobile,
		  				                                 	:message => brochure_url_2,
		  				                                 	:text =>  "",
		  				                                 	:type => "media"
		  				                                  	}.to_json,
		  				                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


							  				                # urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							  				                # result = HTTParty.get(urlstring,
							  				                #         :body => { :phone => mobile,
							  				                #                   :body => brochure_url_2,
							  				                #                   :filename => 'brochure.pdf'  
							  				                #                   }.to_json,
							  				                #        :headers => { 'Content-Type' => 'application/json' } )	
							  								end
							  							elsif number_series[position]=='6'
							  								message=photo_url
							  							elsif number_series[position]=='7'
							  								message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"

							  								urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => '+91'+expert_number,
		  								                 	:message => 'Customer wants to visit site, call him: '+(mobile),
		  								                 	:type => "text"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


							  								# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
							  								# 	  		result = HTTParty.get(urlstring,
							  								# 			   :body => { :phone => '91'+expert_number,
							  								# 			              :body => 'Customer wants to visit site, call him: '+(mobile) 
							  								# 			              }.to_json,
							  								# 			   :headers => { 'Content-Type' => 'application/json' } )
							  								@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
							  								HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})    
							  							elsif number_series[position]=='8'
							  								message=walkthrough_url		
							  							elsif number_series[position]=='9'
							  								message='Kindly click: https://wa.me/91'+expert_number
							  								
							  								urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => '+91'+expert_number,
		  								                 	:message => 'Customer wants to connect, click to chat: https://wa.me/'+mobile,
		  								                 	:type => "text"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

							  								# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
							  								# 	  		result = HTTParty.get(urlstring,
							  								# 			   :body => { :phone => '91'+expert_number,
							  								# 			              :body => 'Customer wants to connect, click to chat: https://wa.me/'+mobile 
							  								# 			              }.to_json,
							  								# 			   :headers => { 'Content-Type' => 'application/json' } )
							  								@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
							  								HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
							  							end
										  			else
											  			if number_series[position].to_i == 0
											  				message=''
											  				break
											  			elsif number_series[position]=='1'
											  				message='👇 Brochure being sent please wait...'
											  				
											  				urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  				                            		@result = HTTParty.post(urlstring,
		  				                               		:body => { :to_number => "+91"+mobile,
		  				                                 	:message => brochure_url,
		  				                                 	:text =>  "",
		  				                                 	:type => "media"
		  				                                  	}.to_json,
		  				                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											  				# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
											      #             result = HTTParty.get(urlstring,
											      #                     :body => { :phone => mobile,
											      #                               :body => brochure_url,
											      #                               :filename => 'brochure.pdf'  
 											     #                                }.to_json,
											      #                    :headers => { 'Content-Type' => 'application/json' } )
											                  if brochure_url_2 != nil
												                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
			  				                            		@result = HTTParty.post(urlstring,
			  				                               		:body => { :to_number => "+91"+mobile,
			  				                                 	:message => brochure_url_2,
			  				                                 	:text =>  "",
			  				                                 	:type => "media"
			  				                                  	}.to_json,
			  				                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											                  # urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
											                  # result = HTTParty.get(urlstring,
											                  #         :body => { :phone => mobile,
											                  #                   :body => brochure_url_2,
											                  #                   :filename => 'brochure.pdf'  
											                  #                   }.to_json,
											                  #        :headers => { 'Content-Type' => 'application/json' } )	
												  				end
											  			elsif number_series[position]=='2'
											  				
											  				urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => '+91'+mobile,
		  								                 	:message => location_link,
		  								                 	:type => "text"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											  				# urlstring =  "https://eu71.chat-api.com/instance124988/sendLink?token=awjkvkwi2sdzv65j"
											                  
											      #             result = HTTParty.get(urlstring,
											      #                     :body => { :phone => mobile,
											      #                               :body => location_link,
											      #                               :title => project_for_bot,
											      #                               :description => address  
											      #                               }.to_json,
											      #                    :headers => { 'Content-Type' => 'application/json' } )
											                  message=location_text
											  			elsif number_series[position]=='3'
											  				message=photo_url
											  			elsif number_series[position]=='4'
											  				message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
											  				
											  				urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => '+91'+expert_number,
		  								                 	:message => 'Customer wants to visit site, call him: '+(mobile),
		  								                 	:type => "text"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											  				# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											  				# 	  		result = HTTParty.get(urlstring,
											  				# 			   :body => { :phone => '91'+expert_number,
											  				# 			              :body => 'Customer wants to visit site, call him: '+(mobile) 
											  				# 			              }.to_json,
											  				# 			   :headers => { 'Content-Type' => 'application/json' } )
											  				@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											  				HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
											  			elsif number_series[position]=='5'
											  				message=about_us_url			
											  			elsif number_series[position]=='6'
											  				message='Kindly click: https://wa.me/91'+expert_number
											  				urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		  								            		@result = HTTParty.post(urlstring,
		  								               		:body => { :to_number => '+91'+expert_number,
		  								                 	:message => 'Customer wants to connect, click to chat: https://wa.me/91'+mobile ,
		  								                 	:type => "text"
		  								                  	}.to_json,
		  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											  				# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											  				# 	  		result = HTTParty.get(urlstring,
											  				# 			   :body => { :phone => '91'+expert_number,
											  				# 			              :body => 'Customer wants to connect, click to chat: https://wa.me/'+mobile 
											  				# 			              }.to_json,
											  				# 			   :headers => { 'Content-Type' => 'application/json' } )
											  				@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											  				HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
											  			elsif number_series[position]=='7'
											  				message=walkthrough_url		
											  			end
											  		end	
										  			if position < (number_length-1)
								  					urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
  								            		@result = HTTParty.post(urlstring,
  								               		:body => { :to_number => '+91'+mobile,
  								                 	:message => message ,
  								                 	:type => "text"
  								                  	}.to_json,
  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

										  			# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
										  			# 	  		result = HTTParty.get(urlstring,
										  			# 			   :body => { :phone => mobile,
										  			# 			              :body => message 
										  			# 			              }.to_json,
										  			# 			   :headers => { 'Content-Type' => 'application/json' } )
										  			end
										  		end
										  	end
										  end
										end
									  
																		

									if project_for_bot=='Dream World City'
										if body.gsub(/\s+/, '')=='1'
											message='👇 Project Summary being sent please wait...'
											
						                	urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => project_summary,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							    #             result = HTTParty.get(urlstring,
							    #                     :body => { :phone => mobile,
							    #                               :body => project_summary,
							    #                               :filename => 'project_summary.pdf'  
							    #                               }.to_json,
							    #                    :headers => { 'Content-Type' => 'application/json' } )
										elsif body.gsub(/\s+/, '')=='2'
											message=ongoing_rate	
										elsif body.gsub(/\s+/, '')=='3'
											message=possession_date	
										elsif body.gsub(/\s+/, '')=='4'
											
				  						urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
					            		@result = HTTParty.post(urlstring,
					               		:body => { :to_number => '+91'+mobile,
					                 	:message => location_link,
					                 	:type => "text"
					                  	}.to_json,
					                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											# urlstring =  "https://eu71.chat-api.com/instance124988/sendLink?token=awjkvkwi2sdzv65j"
							    #             result = HTTParty.get(urlstring,
							    #                     :body => { :phone => mobile,
							    #                               :body => location_link,
							    #                               :title => project_for_bot,
							    #                               :description => address  
							    #                               }.to_json,
							    #                    :headers => { 'Content-Type' => 'application/json' } )
							                message=location_text
										elsif body.gsub(/\s+/, '')=='5'
											message='👇 Brochure being sent please wait...'
											
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => brochure_url,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							    #             result = HTTParty.get(urlstring,
							    #                     :body => { :phone => mobile,
							    #                               :body => brochure_url,
							    #                               :filename => 'brochure.pdf'  
							    #                               }.to_json,
							    #                    :headers => { 'Content-Type' => 'application/json' } )
							                if brochure_url_2 != nil
							                
							                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => brochure_url_2,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


							                # urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							                # result = HTTParty.get(urlstring,
							                #         :body => { :phone => mobile,
							                #                   :body => brochure_url_2,
							                #                   :filename => 'brochure.pdf'  
							                #                   }.to_json,
							                #        :headers => { 'Content-Type' => 'application/json' } )	
											end
										elsif body.gsub(/\s+/, '')=='6'
											message=photo_url
										elsif body.gsub(/\s+/, '')=='7'
											message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
											
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
  								            		@result = HTTParty.post(urlstring,
  								               		:body => { :to_number => '+91'+expert_number,
  								                 	:message => 'Customer wants to visit site, call him: '+(mobile) ,
  								                 	:type => "text"
  								                  	}.to_json,
  								                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											# 	  		result = HTTParty.get(urlstring,
											# 			   :body => { :phone => '91'+expert_number,
											# 			              :body => 'Customer wants to visit site, call him: '+(mobile) 
											# 			              }.to_json,
											# 			   :headers => { 'Content-Type' => 'application/json' } )
											@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
										elsif body.gsub(/\s+/, '')=='8'
											message=walkthrough_url		
										elsif body.gsub(/\s+/, '')=='9'
											message='Kindly click: https://wa.me/91'+expert_number

											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer wants to connect, click to chat: https://wa.me/91'+mobile ,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											# 	  		result = HTTParty.get(urlstring,
											# 			   :body => { :phone => '91'+expert_number,
											# 			              :body => 'Customer wants to connect, click to chat: https://wa.me/'+mobile 
											# 			              }.to_json,
											# 			   :headers => { 'Content-Type' => 'application/json' } )
											@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
										end
									else 
										if body.gsub(/\s+/, '')=='1'
											message='👇 Brochure being sent please wait...'
											
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => brochure_url,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							    #             result = HTTParty.get(urlstring,
							    #                     :body => { :phone => mobile,
							    #                               :body => brochure_url,
							    #                               :filename => 'brochure.pdf'  
							    #                               }.to_json,
							    #                    :headers => { 'Content-Type' => 'application/json' } )
							                if brochure_url_2 != nil
							                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => brochure_url_2,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

							                # urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							                # result = HTTParty.get(urlstring,
							                #         :body => { :phone => mobile,
							                #                   :body => brochure_url_2,
							                #                   :filename => 'brochure.pdf'  
							                #                   }.to_json,
							                #        :headers => { 'Content-Type' => 'application/json' } )	
											end
										elsif body.gsub(/\s+/, '')=='2'
											
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => location_link ,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											# urlstring =  "https://eu71.chat-api.com/instance124988/sendLink?token=awjkvkwi2sdzv65j"
							    #             result = HTTParty.get(urlstring,
							    #                     :body => { :phone => mobile,
							    #                               :body => location_link,
							    #                               :title => project_for_bot,
							    #                               :description => address  
							    #                               }.to_json,
							    #                    :headers => { 'Content-Type' => 'application/json' } )
							                message=location_text
										elsif body.gsub(/\s+/, '')=='3'
											message=photo_url
										elsif body.gsub(/\s+/, '')=='4'
											message="Please mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"
											
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer wants to visit site, call him: '+(mobile) ,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											# 	  		result = HTTParty.get(urlstring,
											# 			   :body => { :phone => '91'+expert_number,
											# 			              :body => 'Customer wants to visit site, call him: '+(mobile) 
											# 			              }.to_json,
											# 			   :headers => { 'Content-Type' => 'application/json' } )
											@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
										elsif body.gsub(/\s+/, '')=='5'
											message=about_us_url			
										elsif body.gsub(/\s+/, '')=='6'
											message='Kindly click: https://wa.me/91'+expert_number
											
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer wants to connect, click to chat: https://wa.me/91'+mobile ,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											# 	  		result = HTTParty.get(urlstring,
											# 			   :body => { :phone => '91'+expert_number,
											# 			              :body => 'Customer wants to connect, click to chat: https://wa.me/'+mobile 
											# 			              }.to_json,
											# 			   :headers => { 'Content-Type' => 'application/json' } )
											@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
										elsif body.gsub(/\s+/, '')=='7'
											message=walkthrough_url		
										end
									end

									multi_words={'brochure'=>['brochur','facilit','specific','plan'],'location'=>['locat','map','address','beyond','beside','near','where','north','south','west','east','around'],'photo'=>['photo','gallery','pic'],'site visit'=>['book','visit','appoint','site'],'company profile'=>['about','company','builder','profile'],'expert chat'=>['chat','expert','human','person','executive','someone','somebody'],'walkthrough'=>['video','walkthrough'],'specific'=>['payment','emi','loan','bank'],'possession'=>['posess','possess','complet','handover','delivery','ready'],'project summary'=>['bhk','cost','price','budget','totalarea','landarea','areaofland','projectdetail','summary','availabl'],'assistance'=>['call','talk','help','assist','contactme','getintouch'],'rate'=>['rate']}

									replies=[]
									multi_words.each do |reply, words|
										words.each do |word|
											if body.gsub(/\s+/, '').downcase.include? word
												replies+=[reply]
											end
										end
									end

									replies=replies.uniq

									if bhk_option==true
										replies=[]
									end

									replies.each do |reply|
										if reply=='brochure'
											message+="\n\n👇 Brochure being sent please wait..."

											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => plan_url,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
						     #            	result = HTTParty.get(urlstring,
						     #                    :body => { :phone => mobile,
						     #                              :body => plan_url,
						     #                              :filename => 'brochure.pdf'  
						     #                              }.to_json,
						     #                   :headers => { 'Content-Type' => 'application/json' } )
		                	                if brochure_url_2 != nil
		                	                
		                	                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => brochure_url_2,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

	
		                	                # urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
		                	                # result = HTTParty.get(urlstring,
		                	                #         :body => { :phone => mobile,
		                	                #                   :body => brochure_url_2,
		                	                #                   :filename => 'brochure.pdf'  
		                	                #                   }.to_json,
		                	                #        :headers => { 'Content-Type' => 'application/json' } )	
		                					end
										elsif reply=='project summary'
											if project_summary==nil
											message+="\n\nFor queries related to price of flat, kindly click https://wa.me/91"+expert_number+" to chat with our executive.\n\nOr call us @ "+expert_number
							            	urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
					            		  		result = HTTParty.get(urlstring,
					            				   :body => { :phone => '91'+expert_number,
					            				              :body => 'Customer asking about price, call him: '+(mobile)+' or, click to chat: https://wa.me/'+mobile 
					            				              }.to_json,
					            				   :headers => { 'Content-Type' => 'application/json' } )
											else
											message+=', 👇 Project Summary being sent please wait...'
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
		                            		@result = HTTParty.post(urlstring,
		                               		:body => { :to_number => "+91"+mobile,
		                                 	:message => project_summary,
		                                 	:text =>  "",
		                                 	:type => "media"
		                                  	}.to_json,
		                                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											# urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
							    #             result = HTTParty.get(urlstring,
							    #                     :body => { :phone => mobile,
							    #                               :body => project_summary,
							    #                               :filename => 'project_summary.pdf'  
							    #                               }.to_json,
							    #                    :headers => { 'Content-Type' => 'application/json' } )
							            	end	
							            elsif reply=='location'
			            					
			            					urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+mobile,
						                 	:message => location_link ,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


			            					# urlstring =  "https://eu71.chat-api.com/instance124988/sendLink?token=awjkvkwi2sdzv65j"
			            	    #             result = HTTParty.get(urlstring,
			            	    #                     :body => { :phone => mobile,
			            	    #                               :body => location_link,
			            	    #                               :title => project_for_bot,
			            	    #                               :description => address  
			            	    #                               }.to_json,
			            	    #                    :headers => { 'Content-Type' => 'application/json' } )
			            	                message+=("\n\n" +location_text)   
							            elsif reply=='photo'
							            	message+=("\n\n"+photo_url)
							            elsif reply=='specific'
							            	message+="\n\nFor specific queries kindly click https://wa.me/91"+expert_number+" to chat with our executive.\n\nOr call us @ "+expert_number
							            	urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
					            		  		result = HTTParty.get(urlstring,
					            				   :body => { :phone => '91'+expert_number,
					            				              :body => 'Customer having specific, call him: '+(mobile)+' or, click to chat: https://wa.me/'+mobile 
					            				              }.to_json,
					            				   :headers => { 'Content-Type' => 'application/json' } )
					            		  	@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	
							            elsif reply=='rate'
							            	if ongoing_rate==nil
											message+="\n\nFor rate/sft related queries kindly click https://wa.me/91"+expert_number+" to chat with our executive.\n\nOr call us @ "+expert_number
											
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer enquiring about rate, call him: '+(mobile)+' or, click to chat: https://wa.me/91'+mobile ,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

						            		@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
					      #       		  		result = HTTParty.get(urlstring,
					      #       				   :body => { :phone => '91'+expert_number,
					      #       				              :body => 'Customer enquiring about rate, call him: '+(mobile)+' or, click to chat: https://wa.me/'+mobile 
					      #       				              }.to_json,
					      #       				   :headers => { 'Content-Type' => 'application/json' } )
							            	else
											message+=("\n\n"+ongoing_rate)	
											end
							            elsif reply=='possession'
							            	if possession_date==nil
							            	message+="\n\nFor possession/completion related queries kindly click https://wa.me/91"+expert_number+" to chat with our executive.\n\nOr call us @ "+expert_number
							            	
							            	urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer enquiring about possession, call him: '+(mobile)+' or, click to chat: https://wa.me/91'+mobile ,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	
						            		@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
							            	# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
					            		 #  		result = HTTParty.get(urlstring,
					            			# 	   :body => { :phone => '91'+expert_number,
					            			# 	              :body => 'Customer enquiring about possession, call him: '+(mobile)+' or, click to chat: https://wa.me/'+mobile 
					            			# 	              }.to_json,
					            			# 	   :headers => { 'Content-Type' => 'application/json' } )
							            	else
							            	message+=("\n\n"+possession_date)	
							            	end
							            elsif reply=='walkthrough'	
							            	message+=("\n\n"+walkthrough_url)
							            elsif reply=='site visit'
							            	message+="\n\nPlease mention your preferred date and time in *dd/mm-hh:mm* format.\n\nFor eg. if you want to visit this *Sunday at 2.30 pm*, you have to type:\n\n*"+Date.today.end_of_week.strftime('%d/%m')+"-02:30*"	
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer wants to visit site, call him: '+(mobile),
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											# 	  		result = HTTParty.get(urlstring,
											# 			   :body => { :phone => '91'+expert_number,
											# 			              :body => 'Customer wants to visit site, call him: '+(mobile) 
											# 			              }.to_json,
											# 			   :headers => { 'Content-Type' => 'application/json' } )
											@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})
										elsif reply=='assistance'
											message+="\n\nOur executive will get in touch with you shortly, to chat with an expert kindly click https://wa.me/91"+expert_number+"\n\nOr you can initiate a call @ "+expert_number
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer wants to connect, click to chat: https://wa.me/91'+mobile,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											# 	  		result = HTTParty.get(urlstring,
											# 			   :body => { :phone => '91'+expert_number,
											# 			              :body => 'Customer wants to connect, click to chat: https://wa.me/'+mobile 
											# 			              }.to_json,
											# 			   :headers => { 'Content-Type' => 'application/json' } )
											@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
										elsif reply=='expert chat'
											message+="\n\nKindly click: https://wa.me/91"+expert_number
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+expert_number,
						                 	:message => 'Customer wants to connect, click to chat: https://wa.me/91'+mobile,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

											# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
											# 	  		result = HTTParty.get(urlstring,
											# 			   :body => { :phone => '91'+expert_number,
											# 			              :body => 'Customer wants to connect, click to chat: https://wa.me/'+mobile 
											# 			              }.to_json,
											# 			   :headers => { 'Content-Type' => 'application/json' } )
											@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
											HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})	  		
										elsif reply=='company profile'	
											message+=("\n\n"+about_us_url)
							            end
							        end
							        if message[0..1]=="\n\n"
							        	message[0..1]=''
							        end
				
									# whatsapp creation, we will be sending message, by_lead, lead_id
									
									url_encoded_body=CGI.escape(body)
									urlstring =  "https://www.realtybucket.com/webhook/create_whatsapp?lead_id="+(bot_lead_id)+'&message='+url_encoded_body+'&by_lead=true'
						            whatsapp_creation_result = HTTParty.get(urlstring)

						            if bhk_option==true
										jain_group_message='bhk and budget options given'
									elsif channel_partner_option != nil
										jain_group_message=channel_partner_option
									elsif message != ''	
									urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+mobile,
						                 	:message => message,
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

									# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
									# 	  		result = HTTParty.get(urlstring,
									# 			   :body => { :phone => mobile,
									# 			              :body => message 
									# 			              }.to_json,
									# 			   :headers => { 'Content-Type' => 'application/json' } )
									jain_group_message=message
									else
										if body.gsub(/\s+/, '').downcase == 'rajarhat' || body.gsub(/\s+/, '').downcase == 'joka' || body.gsub(/\s+/, '').downcase == 'interestedindreamone' || body.gsub(/\s+/, '').downcase == 'interestedindreamworldcity' || body.gsub(/\s+/, '').downcase == 'interestedindreamonehotel'
										jain_group_message=body.gsub(/\s+/, '').downcase
										else
											urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
						            		@result = HTTParty.post(urlstring,
						               		:body => { :to_number => '+91'+mobile,
						                 	:message => "Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/91"+expert_number+" to chat with our executive.\n\nOr call us @ "+expert_number+"\n\nThanks & Regards,\nJain Group",
						                 	:type => "text"
						                  	}.to_json,
						                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	

										# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
										#   		result = HTTParty.get(urlstring,
										# 		   :body => { :phone => mobile,
										# 		              :body => "Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/91"+expert_number+" to chat with our executive.\n\nOr call us @ "+expert_number+"\n\nThanks & Regards,\nJain Group" 
										# 		              }.to_json,
										# 		   :headers => { 'Content-Type' => 'application/json' } )
										
										urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
					            		@result = HTTParty.post(urlstring,
					               		:body => { :to_number => '+91'+expert_number,
					                 	:message => "Whatsapp BOT failed, please connect with customer, call: "+(mobile)+ " , or click to chat: https://wa.me/91"+mobile+"\n\nCustomer's Message: "+body,
					                 	:type => "text"
					                  	}.to_json,
					                  	:headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    	


										# urlstring =  "https://eu71.chat-api.com/instance124988/sendMessage?token=awjkvkwi2sdzv65j"
										# 	  		result = HTTParty.get(urlstring,
										# 			   :body => { :phone => '91'+expert_number,
										# 			              :body => "Whatsapp BOT failed, please connect with customer, call: "+(mobile)+ " , or click to chat: https://wa.me/"+mobile+"\n\nCustomer's Message: "+body 
										# 			              }.to_json,
										# 			   :headers => { 'Content-Type' => 'application/json' } )
										@urlstring='http://www.realtybucket.com/webhook/lead_reengaged'
										HTTParty.post(@urlstring, :body => {"mobile" => mobile, "project" => project_for_bot})			     		
										jain_group_message="Sorry I could not understand, in case I am unable to assist you kindly click https://wa.me/91"+expert_number+" to chat with our executive.\n\nOr call us @ "+expert_number+"\n\nThanks & Regards,\nJain Group"
										end
									end

									url_encoded_body=CGI.escape(jain_group_message)
									urlstring =  "https://www.realtybucket.com/webhook/create_whatsapp?lead_id="+(bot_lead_id)+'&message='+url_encoded_body
						            whatsapp_creation_result = HTTParty.get(urlstring)
									# alcove_whatsapp.save
									
								end

							end	
							

							

				end

					  		
			end
		end
	render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def click_to_call
	  	@lead = Lead.find(params[:lead_id])
	  	@agent_number = params[:agent_number]
	  	executives = Personnel.where(organisation_id: 1).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
		@executives=[]
		executives.each do |executive|
			@executives+=[[executive.name, executive.id]]
		end
		@executives.sort!
		@age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
		@areas = selectoptions_with_other(Area, :name).sort
		@occupations = selectoptions_with_other(Occupation, :description).sort
		@lost_reasons = selectoptions(LostReason, :description)	
		@common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
		if @lead.follow_ups==[] && @lead.whatsapps==[]
			flash[:danger]='no followup history present'
			redirect_to :back
		else
		end
	  	urlstring = "https://kpi.knowlarity.com/Basic/v1/account/call/makecall"
	    cli_number = "+918068323257"
	    result = HTTParty.post(urlstring,
	    :body => { 
	                :k_number => "+919681411411",
	                :agent_number => "+91"+@agent_number.to_s,
	                :customer_number => "+91"+@lead.mobile.to_s,
	                :caller_id => cli_number
	            }.to_json,
	   	:headers => { 'Content-Type' => 'application/json','Accept' => 'application/json','Authorization' => 'dff4b494-13d3-4c18-b907-9a830de783ef','x-api-key' => 'LnUmJ62yqp31VLKYR4YlfrYtYOKNIC59viqOXh8g'} )
	end

	def followup_update
		followup = FollowUp.new
		followup.lead_id = params[:leading_id].to_i
		followup.communication_time = params[:leading][:flexible_date]
		followup.follow_up_time = params[:leading][:followup_date]
		followup_hours = params[:leading]['followup_time(4i)'].to_i*60*60
		followup_minutes = params[:leading]['followup_time(5i)'].to_i*60
		followup.follow_up_time = followup.follow_up_time+followup_hours+followup_minutes
		followup.remarks = params[:remarks]
		telephony_call = TelephonyCall.where(lead_id: params[:leading_id].to_i, untagged: true).sort_by{|x| x.created_at}.last
		if telephony_call == nil
		else
			followup.telephony_call_id = telephony_call.id
		end
		followup.personnel_id = Personnel.find(Lead.find(followup.lead_id).personnel.mapped).id
		followup.last = true
		followup.save
		
		flash[:success]	= 'Followup Updated Successfully.'
		redirect_to :back
	end
end