class MarketingAutomationController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:referral_scheme_opt, :referred_lead_form]

	def email_template_index
		@business_units = selections_with_all(BusinessUnit, :name)
		@email_types=['All','Lost','Live','Ad hoc','Birthday wish','Anniversary Wish', 'Fresh', 'Organised Visit', 'Site Visited', 'Booked','Introductory','On subscription','Congratulation on Booking']
		if params[:business_unit_id] == nil
			@email_templates=EmailTemplate.where(organisation_id: current_personnel.organisation_id, inactive: nil)
			@email_template_type='All'
		else
			@business_unit_id = params[:business_unit_id]
			@email_template_type=params[:email_template][:email_type]				
			@inactive=params[:inactive]
		    if params[:email_template][:email_type]== 'All'
		    	if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, inactive: true)
				else 
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Lost'
		    	if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, lost: true, inactive: true)
				else 
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, lost: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Live'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, live: true, inactive: true)
				else 
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, live: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Ad hoc'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, ad_hoc: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, ad_hoc: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Birthday wish'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, birthday_wish: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, birthday_wish: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Anniversary Wish'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, anniversary_wish: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, anniversary_wish: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Fresh'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, fresh: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, fresh: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Organised Visit'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, organised_visit: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, organised_visit: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Site Visited'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, site_visited: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, site_visited: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Booked'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, Booked: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, Booked: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Introductory'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, introductory: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, introductory: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'On subscription'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, on_subscription: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, on_subscription: true, inactive: nil)
				end
			elsif params[:email_template][:email_type]== 'Congratulation on Booking'
				if @inactive == "true"
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, congratulation_on_booking: true, inactive: true)
				else
					@email_templates= EmailTemplate.where(business_unit_id: @business_unit_id.to_i, congratulation_on_booking: true, inactive: nil)
				end
			end 
		end
	end

	def email_template_new
		@email_template=EmailTemplate.new
		@business_units=selections(BusinessUnit, :name)
		@email_types=['Lost','Live','Ad hoc','Birthday wish','Anniversary Wish', 'Fresh', 'Organised Visit', 'Site Visited', 'Booked', 'Introductory', 'On subscription', 'Congratulation on Booking']
		@email_template_action='email_template_create'
	end

	def email_template_create
		email_template=EmailTemplate.new(email_template_params)
		if params[:email_type]== 'Lost'
			email_template.lost = true
		elsif params[:email_type] == 'Live'
			email_template.live = true
		elsif params[:email_type] == 'Ad hoc'
			email_template.ad_hoc = true
		elsif params[:email_type] == 'Birthday wish'
			email_template.birthday_wish = true
		elsif params[:email_type] == 'Anniversary Wish'
			email_template.anniversary_wish = true
		elsif params[:email_type] == 'Fresh'
			email_template.fresh = true
		elsif params[:email_type] == 'Organised Visit'
			email_template.organised_visit = true
		elsif params[:email_type] == 'Site Visited'
			email_template.site_visited = true
		elsif params[:email_type] == 'Booked'
			email_template.Booked = true
		elsif params[:email_type] == 'Introductory'
			email_template.introductory = true
		elsif params[:email_type] == 'On subscription'
			email_template.on_subscription = true
		elsif params[:email_type] == 'Congratulation on Booking'
			email_template.congratulation_on_booking = true
		end
		
		email_template.organisation_id=current_personnel.organisation_id
		email_template.save

		flash[:success]='Email Template Generated successfully.'
		redirect_to marketing_automation_email_template_index_url
	end

	def email_template_edit
		@email_template=EmailTemplate.find(params[:format])
		@business_units=selections(BusinessUnit, :name)
		@email_template_action='email_template_update'
		@email_types=['Lost','Live','Ad hoc','Birthday wish','Anniversary Wish','Fresh','Organised Visit','Site Visited','Booked','Introductory','On subscription','Congratulation on Booking']
	end

	def email_template_update
		@email_template= EmailTemplate.find(params[:email_template_id])
  		@email_template.update(email_template_params)
  		if params[:email_type]== 'Lost'
			@email_template.update(lost: true, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Live'
			@email_template.update(live: true, lost: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Ad hoc'
			@email_template.update(ad_hoc: true, lost: nil, live: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Birthday wish'
			@email_template.update(birthday_wish: true, live: nil, ad_hoc: nil, anniversary_wish: nil, lost: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Anniversary Wish'
			@email_template.update(anniversary_wish: true, live: nil, ad_hoc: nil, birthday_wish: nil, lost: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Fresh'
			@email_template.update(fresh: true,lost: nil, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, organised_visit: nil, site_visited: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Organised Visit'
			@email_template.update(organised_visit: true, lost: nil, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, site_visited: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Site Visited'
			@email_template.update(site_visited: true,lost: nil, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, Booked:nil,  introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Booked'
			@email_template.update(Booked:true, lost: nil, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, site_visited: nil, introductory: nil,on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Introductory'
			@email_template.update(introductory: true, lost: nil, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked: nil, on_subscription: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'On subscription'
			@email_template.update(on_subscription: true, lost: nil, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked: nil,introductory: nil, congratulation_on_booking: nil)
		elsif params[:email_type] == 'Congratulation on Booking'
			@email_template.update(congratulation_on_booking: true, lost: nil, live: nil, ad_hoc: nil, birthday_wish: nil, anniversary_wish: nil, fresh: nil, organised_visit: nil, site_visited: nil, Booked: nil, introductory: nil,on_subscription: nil )
		end
		if params[:email_template][:inactive] == "true"
			@email_template.update(inactive: true)
		else 
			@email_template.update(inactive: nil)
		end
	
		flash[:success]='Email Template Updated successfully.'
		redirect_to marketing_automation_email_template_index_url
	end

	def email_template_destroy
		@email_template=EmailTemplate.find(params[:format])
		@email_template.destroy

		flash[:success]='Email Template destroyed successfully.'
		redirect_to marketing_automation_email_template_index_url
	end

	def email_template_preview_index
		@email_template=EmailTemplate.find(params[:format])
	end

	def testing_email_template_send
		email_template_id=params[:email_template_id]
		email_id=params[:email_id]
		data=[]
		data=[email_id, email_template_id, current_personnel.id]
		UserMailer.testing_email_send(data).deliver      

		flash[:success]='Email Template send successfully.'
		redirect_to marketing_automation_email_template_index_url
	end

	def whatsapp_template_index
		@business_units = selections_with_all(BusinessUnit, :name)
		if params[:business_unit_id] == nil
			@whatsapp_templates = []
			@business_unit_id = -1
		else
			@business_unit_id = params[:business_unit_id]
			@whatsapp_templates = WhatsappTemplate.where(business_unit_id: @business_unit_id.to_i, inactive: nil)
	    end	
	end

	def whatsapp_template_new
		@whatsapp_template = WhatsappTemplate.new
		@business_units = selections(BusinessUnit, :name)
		@template_types = ["pdf", "video", "text", "image", "image with text", "pdf with text", "video with text", "image with text and quickreply button", "pdf with text and quickreply button", "video with text and quickreply button", "image with text and one link button"]
		@lead_types = ["live","lost","adhoc","fresh","site visited","booked","qualified", "OV"]
		@whatsapp_template_action='whatsapp_template_create'
	end

	def whatsapp_template_create
		whatsapp_template = WhatsappTemplate.new(whatsapp_template_params)
		whatsapp_template.organisation_id = current_personnel.organisation_id
		whatsapp_template.save
		if params[:whatsapp_template][:lead_type] == "live"
			whatsapp_template.update(live: true, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "lost"
			whatsapp_template.update(live: nil, lost: true, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "adhoc"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: true, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "fresh"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: true, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "site visited"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: true, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "booked"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: true, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "qualified"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: true, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "OV"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: true)
		else
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		end

		flash[:success] = 'Whatsapp Template Generated successfully.'
		redirect_to marketing_automation_whatsapp_template_index_url
	end

	def whatsapp_template_edit
		@whatsapp_template = WhatsappTemplate.find(params[:format])
		@business_units = selections(BusinessUnit, :name)
		@template_types = ["pdf", "video", "text", "image", "image with text", "pdf with text", "video with text", "image with text and quickreply button", "pdf with text and quickreply button", "video with text and quickreply button", "image with text and one link button"]
		@lead_types = ["live","lost","adhoc","fresh","site visited","booked","qualified", "OV"]
		@whatsapp_template_action = 'whatsapp_template_update'
	end

	def whatsapp_template_update
		whatsapp_template = WhatsappTemplate.find(params[:whatsapp_template_id])
  		whatsapp_template.update(whatsapp_template_params)
		if params[:whatsapp_template][:inactive] == "true"
			whatsapp_template.update(inactive: true)
		else 
			whatsapp_template.update(inactive: nil)
		end
		if params[:whatsapp_template][:lead_type] == "live"
			whatsapp_template.update(live: true, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "lost"
			whatsapp_template.update(live: nil, lost: true, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "adhoc"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: true, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "fresh"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: true, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "site visited"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: true, Booked: nil, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "booked"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: true, qualified: nil, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "qualified"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: true, visit_organised: nil)
		elsif params[:whatsapp_template][:lead_type] == "OV"
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: true)
		else
			whatsapp_template.update(live: nil, lost: nil, ad_hoc: nil, fresh: nil, site_visited: nil, Booked: nil, qualified: nil, visit_organised: nil)
		end
	
		flash[:success] = 'Whatsapp Template Updated successfully.'
		redirect_to marketing_automation_whatsapp_template_index_url
	end

	def whatsapp_template_destroy
		@whatsapp_template = WhatsappTemplate.find(params[:format])
		@whatsapp_template.destroy

		flash[:success] = 'Whatsapp Template destroyed successfully.'
		redirect_to marketing_automation_whatsapp_template_index_url
	end

	def whatsapp_template_preview_index		
		@whatsapp_template = WhatsappTemplate.find(params[:format])
		@body = @whatsapp_template.body

		@str = @body.chars.to_a
		if first_star_position=@str[0..@str.length].index('*')
			(first_star_position..@str.length).each do |index|
				next_star_position=@str[first_star_position+1..@str.length-1].index('*')
				if next_star_position == nil
					second_star_position=first_star_position
				else
					second_star_position=first_star_position+next_star_position+1
				end
				if @str[first_star_position+1]==" "|| @str[second_star_position-1]==" "
					third_star_position=second_star_position+1+(@str[second_star_position+1..@str.length].index('*'))
					first_star_position=third_star_position
				elsif @str[first_star_position+1]!=" " && @str[second_star_position-1]!=" "
					@str[first_star_position]= '<b>'
					@str[second_star_position]= '</b>'
					if second_star_position == @str.length-1
						break
					else
						another_star_position=@str[second_star_position+1..@str.length].index('*')
						if another_star_position == nil || another_star_position == ''
							break
						else
							third_star_position=second_star_position+1+another_star_position
							first_star_position=third_star_position
						end
					end
				end
			end
		end
		if first_underscore_position=@str[0..@str.length].index('_')
			(first_underscore_position..@str.length).each do |index|
				next_underscore_position=@str[first_underscore_position+1..@str.length-1].index('_')
				if next_underscore_position == nil
					second_underscore_position=first_underscore_position
				else
					second_underscore_position=first_underscore_position+next_underscore_position+1
				end
				if @str[first_underscore_position+1]==" "|| @str[second_underscore_position-1]==" "
					third_underscore_position=second_underscore_position+1+(@str[second_underscore_position+1..@str.length].index('_'))
					first_underscore_position=third_underscore_position
				elsif @str[first_underscore_position+1]!=" " && @str[second_underscore_position-1]!=" "
					@str[first_underscore_position]= '<i>'
					@str[second_underscore_position]= '</i>'
					if second_underscore_position == @str.length-1
						break
					else
						another_underscore_position=@str[second_underscore_position+1..@str.length].index('_')
						if another_underscore_position == nil || another_underscore_position == ''
							break
						else
							third_underscore_position=second_underscore_position+1+another_underscore_position
							first_underscore_position=third_underscore_position
						end
					end
				end
			end
		end
		
		# ********************************************************************************************************
		# if first_underscore_position=@str[0..@str.length].index('_')
		# 	(first_underscore_position..@str.length).each do |index|
		# 		next_underscore_position=@str[first_underscore_position+1..@str.length-1].index('_')
		# 		if next_underscore_position == nil
		# 			second_underscore_position=first_underscore_position
		# 		else
		# 			second_underscore_position=first_underscore_position+next_underscore_position+1
		# 		end
		# 		if @str[first_underscore_position+1]==" " || @str[second_underscore_position-1]==" " || (@str[first_underscore_position-1] !="d" && @str[first_underscore_position-2] !="l" && @str[first_underscore_position-3] !="e" && @str[first_underscore_position-4] !="i" && @str[first_underscore_position-5] !="f") 
		# 			third_underscore_position=second_underscore_position+1+(@str[second_underscore_position+1..@str.length].index('_'))
		# 			first_underscore_position=third_underscore_position
		# 		elsif @str[first_underscore_position+1]!=" " && @str[second_underscore_position-1]!=" " && @str[first_underscore_position-1] !="d" && @str[first_underscore_position-2] !="l" && @str[first_underscore_position-3] !="e" && @str[first_underscore_position-4] !="i" && @str[first_underscore_position-5] !="f"
		# 			@str[first_underscore_position]= '<i>'
		# 			@str[second_underscore_position]= '</i>'
		# 			if second_underscore_position == @str.length-1
		# 				break
		# 			else
		# 				another_underscore_position=@str[second_underscore_position+1..@str.length].index('_')
		# 				if another_underscore_position == nil || another_underscore_position == ''
		# 					break
		# 				else
		# 					third_underscore_position=second_underscore_position+1+another_underscore_position
		# 					first_underscore_position=third_underscore_position
		# 				end
		# 			end
		# 		end
		# 	end
		# end

		# ***************************************************************************************************************************
		@str.each_with_index do |new_line, index|
			if new_line == "\r"
				@str[index] = +" "+"<br>"+" "
			elsif new_line == "\n"
				@str[index] = new_line.to_s+" "
			end
		end
		@final_string=''
		@str.each do |val|
			@final_string+=val
		end
	end

	def testing_whatsapp_template_send
		if params[:commit]=='send'
			whatsapp_template_id = params[:whatsapp_template_id]
			whatsapp_number = params[:whatsapp_number]
			@whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
			if (@whatsapp_template.file_name == nil || @whatsapp_template.file_name == '') && (@whatsapp_template.file_url == nil || @whatsapp_template.file_url == '')
				urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
	            result = HTTParty.post(urlstring,
	               :body => { :to_number => '+91'+whatsapp_number.to_s,
	                 :message => @whatsapp_template.body,    
	                  :type => "text"
	                  }.to_json,
	                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
			else
				urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
	            result = HTTParty.post(urlstring,
	               :body => { :to_number => '+91'+whatsapp_number.to_s,
	                 :message => @whatsapp_template.file_url,    
	                  :text => "",
	                  :type => "media"
	                  }.to_json,
	                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
			end
		elsif params[:commit]=='Bulk Recipient Send'
			bulk_recipients=BulkRecipient.where(organisation_id: current_personnel.organisation_id)
			bulk_recipients.each do |bulk_recipient|
				bulk_recipient.update(to_send: true)
			end
		end
		flash[:success]='Whatsapp Template send successfully.'
		redirect_to marketing_automation_whatsapp_template_index_url
	end

	def email_image_upload_form
		@email_template_id=EmailTemplate.find(params[:format]).id
	end

	def email_image_upload
		email_template=EmailTemplate.find(params[:email_template_id])
		if params[:pics]
		  params[:pics].each { |pic|
		  email_template.email_attachments.create(data: pic)
		  }
		end
		redirect_to :back
	end

	def email_image_index
		@email_images=EmailImage.all
	end


	def whatsapp_image_upload_form
		@whatsapp_template_id=WhatsappTemplate.find(params[:format]).id
	end

	def whatsapp_image_upload
		whatsapp_template=WhatsappTemplate.find(params[:whatsapp_template_id])
		if params[:pics]
		  params[:pics].each { |pic|
		  	whatsapp_template.whatsapp_images.create(image: pic)
		  }
		end
		redirect_to :back
	end

	def whatsapp_image_index
		@whatsapp_images=WhatsappImage.all
	end



	def bulk_recipient_index
		@bulk_recipients=BulkRecipient.where(organisation_id: current_personnel.organisation_id)
		@total_bulk_recipients=@bulk_recipients.count
		@recipients_sent=@bulk_recipients.where(whatsapp_sent: true).count
		@recipients_not_sent=@bulk_recipients.where(whatsapp_sent: false).count		
	end

	def bulk_recipient_upload_form
	end

	def bulk_recipient_upload
		errors=BulkRecipient.import(params[:file], current_personnel.organisation_id)
		if errors.count>0
			flash[:danger]="Leads imported with error-"+errors.count.to_s
		else	
			flash[:info]="Leads imported!"
		end
		redirect_to marketing_automation_bulk_recipient_index_url
	end

	def bulk_recipient_submit
		if params[:commit]=='Destroy'
	  		redirect_to controller: 'marketing_automation', action: 'bulk_recipient_destroy', params: request.request_parameters 
	  	elsif params[:commit]=='Retry'
			redirect_to controller: 'marketing_automation', action: 'bulk_recipient_clear', params: request.request_parameters 
	  	elsif params[:commit]=='Destroy All'
	  		params[:bulk_recipient_ids].each{|x| BulkRecipient.find(x).destroy}
	  		redirect_to :back
	  	end
	end

	def bulk_recipient_destroy
		bulk_recipient_ids=params[:bulk_recipient_ids]
		bulk_recipient_ids.each do |bulk_recipient|
			recipient=BulkRecipient.find(bulk_recipient)
			recipient.destroy
		end	

		flash[:info]="Bulk Recipient Destroyed Successfully."
		redirect_to marketing_automation_bulk_recipient_index_url
	end

	def bulk_recipient_clear
		bulk_recipient_ids=params[:bulk_recipient_ids]
		bulk_recipient_ids.each do |bulk_recipient|
			recipient=BulkRecipient.find(bulk_recipient)
			recipient.whatsapp_sent = nil
			recipient.remarks = nil
			recipient.save
		end	

		flash[:info]="Bulk Recipient Retry Done."
		redirect_to marketing_automation_bulk_recipient_index_url
	end

	def sms_template_index
		if params[:sms_template]==nil
			@sms_templates=SmsTemplate.where(organisation_id: current_personnel.organisation_id, inactive: nil)
		    @sms_types=['All','Lost','Live','Ad hoc','Birthday wish','Anniversary Wish', 'Fresh', 'Organised Visit', 'Site Visited', 'Booked','Introductory','On subscription','Congratulation on Booking']
		    @sms_template_type='All'
		else
			@sms_types=['All','Lost','Live','Ad hoc','Birthday wish','Anniversary Wish', 'Fresh', 'Organised Visit', 'Site Visited', 'Booked','Introductory','On subscription','Congratulation on Booking']
			@sms_template_type=params[:sms_template][:sms_type]				
			@inactive=params[:inactive]
		    if params[:sms_template][:sms_type]== 'All'
		    	if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Lost'
		    	if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, lost: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, lost: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Live'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, live: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, live: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Ad hoc'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, ad_hoc: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, ad_hoc: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Birthday wish'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, birthday_wish: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, birthday_wish: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Anniversary Wish'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, anniversary_wish: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, anniversary_wish: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Fresh'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, fresh: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, fresh: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Organised Visit'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, organised_visit: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, organised_visit: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Site Visited'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, site_visited: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, site_visited: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Booked'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, Booked: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, Booked: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Introductory'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, introductory: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, introductory: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'On subscription'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, on_subscription: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, on_subscription: true, inactive: nil)
				end
			elsif params[:sms_template][:sms_type]== 'Congratulation on Booking'
				if @inactive == "true"	    		
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, congratulation_on_booking: true, inactive: true)
				else
					@sms_templates= SmsTemplate.where(organisation_id: current_personnel.organisation_id, congratulation_on_booking: true, inactive: nil)
				end
			end 
	    end	 		
	end	

	def sms_template_new
		@sms_template=SmsTemplate.new
		@business_units=selections(BusinessUnit, :name)
		@sms_types=['Lost','Live','Ad hoc','Birthday wish','Anniversary Wish', 'Fresh', 'Organised Visit', 'Site Visited', 'Booked']
		@sms_template_action='sms_template_create'
	end

	def sms_template_create
		sms_template=SmsTemplate.new(sms_template_params)
		if params[:sms_type]== 'Lost'
			sms_template.lost = true
		elsif params[:sms_type] == 'Live'
			sms_template.live = true
		elsif params[:sms_type] == 'Ad hoc'
			sms_template.ad_hoc = true
		elsif params[:sms_type] == 'Birthday wish'
			sms_template.birthday_wish = true
		elsif params[:sms_type] == 'Anniversary Wish'
			sms_template.anniversary_wish = true
		elsif params[:sms_type] == 'Fresh'
			sms_template.fresh = true
		elsif params[:sms_type] == 'Organised Visit'
			sms_template.organised_visit = true
		elsif params[:sms_type] == 'Site Visited'
			sms_template.site_visited = true
		elsif params[:sms_type] == 'Booked'
			sms_template.booked = true
		end
		
		sms_template.organisation_id=current_personnel.organisation_id
		sms_template.save

		flash[:success]='SMS Template Generated successfully.'
		redirect_to marketing_automation_sms_template_index_url
	end

	def sms_template_edit
		@sms_template=SmsTemplate.find(params[:format])
		@business_units=selections(BusinessUnit, :name)
		@sms_types=['Lost','Live','Ad hoc','Birthday wish','Anniversary Wish', 'Fresh', 'Organised Visit', 'Site Visited', 'Booked']
		@sms_template_action='sms_template_update'
	end

	def sms_template_update
		@sms_template=SmsTemplate.find(params[:sms_template_id])
  		@sms_template.update(sms_template_params)
    	if params[:sms_type]== 'Lost'
			@sms_template.update(lost: true, live: nil, ad_hoc: nil)
		elsif params[:sms_type] == 'Live'
			@sms_template.update(live: true, lost: nil, ad_hoc: nil)
		elsif params[:sms_type] == 'Ad hoc'
			@sms_template.update(ad_hoc: true, lost: nil, live: nil)
		elsif params[:sms_type] == 'Birthday wish'
			@sms_template.update(birthday_wish: true, live: nil, ad_hoc: nil, anniversary_wish: nil, lost: nil)
		elsif params[:sms_type] == 'Anniversary Wish'
			@sms_template.update(anniversary_wish: true, live: nil, ad_hoc: nil, birthday_wish: nil, lost: nil)
		elsif params[:sms_type] == 'Fresh'
			@sms_template.update(fresh: true, anniversary_wish: nil, live: nil, ad_hoc: nil, birthday_wish: nil, lost: nil)
		elsif params[:sms_type] == 'Organised Visit'
			@sms_template.update(organised_visit: true, fresh: nil, anniversary_wish: nil, live: nil, ad_hoc: nil, birthday_wish: nil, lost: nil)
		elsif params[:sms_type] == 'Site Visited'
			@sms_template.update(site_visited: true, organised_visit: nil, fresh: nil, anniversary_wish: nil, live: nil, ad_hoc: nil, birthday_wish: nil, lost: nil)
		elsif params[:sms_type] == 'Booked'
			@sms_template.update(booked:true, site_visited: nil, organised_visit: nil, fresh: nil, anniversary_wish: nil, live: nil, ad_hoc: nil, birthday_wish: nil, lost: nil)
		end
		if params[:sms_template][:inactive] == "true"
			@sms_template.update(inactive: true)
		else 
			@sms_template.update(inactive: nil)
		end
	
		flash[:success]='SMS Template Updated successfully.'
		redirect_to marketing_automation_sms_template_index_url
	end

	def sms_template_destroy
		@sms_template=SmsTemplate.find(params[:format])
		@sms_template.destroy

		flash[:success]='SMS Template destroyed successfully.'
		redirect_to marketing_automation_sms_template_index_url
	end

	def sms_template_preview_index
		@sms_template=SmsTemplate.find(params[:format])
		p @sms_template.body
		@final_string=@sms_template.body.gsub("\r\n", " "+"<br>"+" ")
		p @final_string
	end

	def testing_sms_template_send
		sms_template=SmsTemplate.find(params[:sms_template_id])
		text=sms_template.body
		text=text.to_s.gsub("\r\n","%0a")
		p text
		if params[:commit]=='send'
			number='91'+params[:sms_number]
			urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=JAINGR&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
			response=HTTParty.get(urlstring)
		elsif params[:commit]=='Bulk Recipient Send'
			BulkRecipient.where(organisation_id: current_personnel.organisation_id, sms_sent: nil).each do |recipient|
				number='91'+recipient.mobile
				urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid=JAINGR&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
				response=HTTParty.get(urlstring)
			end
		end 

		flash[:success]='SMS Template send successfully.'
		redirect_to marketing_automation_sms_template_index_url
	end
# ****************************************Wish to custumer *********************************************************
	def wish_to_customer_index
		@wish_to_customers=WishToCustomer.all
	end

	def wish_to_customer_upload_form
	end

	def wish_to_customer_upload
		errors=WishToCustomer.import(params[:file], current_personnel.organisation_id)
		if errors.count>0
			flash[:danger]="Customers imported with error-"+errors.count.to_s
		else	
			flash[:info]="Customers imported!"
		end
		redirect_to marketing_automation_wish_to_customer_index_url
	end

	def wish_to_customer_submit
		if params[:commit]=='Retry'
			redirect_to controller: 'marketing_automation', action: 'wish_to_customer_clear', params: request.request_parameters 
	  	elsif params[:commit]=='Destroy All'
	  		params[:wish_to_customer_ids].each{|x| WishToCustomer.find(x).destroy}
	  		redirect_to :back
	  	elsif params[:commit]=='Edit'
			redirect_to controller: 'marketing_automation', action: 'wish_to_customer_edit', params: request.request_parameters 

	  	end
	end
	def wish_to_customer_edit
		@wish_to_customer=WishToCustomer.find(params[:format])
		@wish_to_customer_action='wish_to_customer_update'
	end

	def wish_to_customer_update
		@wish_to_customer=WishToCustomer.find(params[:wish_to_customer_id])
		@wish_to_customer.update(wish_to_customer_params)

		redirect_to marketing_automation_wish_to_customer_index_url
	end

	def wish_to_customer_destroy
		wish_to_customer_ids=params[:wish_to_customer_ids]
		wish_to_customer_ids.each do |wish_to_customer|
			recipient=WishToCustomer.find(wish_to_customer)
			recipient.destroy
		end	

		flash[:success]="customer Destroyed Successfully."
		redirect_to marketing_automation_wish_to_customer_index_url

	end

	def wish_to_customer_clear
		wish_to_customer_ids=params[:wish_to_customer_ids]
		wish_to_customer_ids.each do |wish_to_customer|
			recipient=WishToCustomer.find(wish_to_customer)
			recipient.whatsapp_sent = nil
			recipient.remarks = nil
			recipient.save
		end	

		flash[:success]="Customers Retry Done."
		redirect_to marketing_automation_wish_to_customer_index_url
	end

	def referred_leads_index
		# @referred_leads = ReferredLead.includes(:wish_to_customer, :lead).where(:wish_to_customers => {organisation_id: current_personnel.organisation_id})
		@referred_leads = ReferredLead.all
	end

	def referred_lead_form
	end

	def referred_lead_create
		lead=Lead.new
		lead.name = params[:lead][:name]
		lead.email = params[:lead][:email]
		lead.mobile = params[:lead][:mobile]
		lead.save

		referred_lead=ReferredLead.new
		# referred_lead.wish_to_customer = old_lead_id
		referred_lead.lead_id = lead.id
		referred_lead.save

		flash[:success]="Lead Created Successfully."
		redirect_to marketing_automation_referred_leads_index_url
	end
	def referral_scheme_opt
		@wish_to_customer=WishToCustomer.find(params[:wish_to_customer_id])
		if params[:opt_in]==true
			@wish_to_customer.update(opt_in: true)
		elsif params[:opt_in]==false
			@wish_to_customer.update(opt_in: false)	
		end
	end

	# ----------------------------------------------------------------------------------------------------------------------

  private
    
    def email_template_params
    	params.require(:email_template).permit(:business_unit_id, :send_after_days, :body, :title, :inactive, :file_name, :file_url)
    end

    def whatsapp_template_params
    	params.require(:whatsapp_template).permit(:business_unit_id, :send_after_days, :body, :title, :inactive, :file_name, :file_url, :template_type, :name_required)
    end

    def sms_template_params
    	params.require(:sms_template).permit(:business_unit_id, :send_after_days, :body, :title, :inactive)
    end
    def wish_to_customer_params
    	params.require(:wish_to_customer).permit(:name, :email, :mobile, :dob, :doa, :field_one, :field_two, :field_three)
    end
end
