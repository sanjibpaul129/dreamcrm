class TransactionController < ApplicationController
  def index
  end

  def personnel_notes
    notes = params[:notes]
    current_personnel.update(notes: notes)
    
    flash[:success] = "Note Save Successfully."
    redirect_to :back
  end

  def customer_followup_entry
    lead = Lead.find(params[:lead_id].to_i)
    lead.call_the_customer

    if current_personnel.status=='Admin' || current_personnel.status=='Back Office' || current_personnel.status=='Sales Executive'  || current_personnel.status=='Team Lead'  || current_personnel.status=='Marketing' || current_personnel.status == "Audit"
      executives=Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
      @executives=[]
      executives.each do |executive|
        @executives+=[[executive.name, executive.id]]
      end
      @executives.sort!
    end
    @lost_reasons=selections(LostReason, :description)  
    @common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
    @age_brackets = ['Young', 'Middle Age', 'Old Age'].sort
    @areas = selections_with_other(Area, :name).sort
    @occupations=selections_with_other(Occupation, :description).sort
  end

  def sr_fresh_leads
    @telephony_calls = TelephonyCall.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}, fresh: true, agent_number: current_personnel.mobile)
    executives=Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
    @executives=[]
    executives.each do |executive|
      @executives+=[[executive.name, executive.id]]
    end
    @executives.sort!
    @lost_reasons=selections(LostReason, :description)
    @common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
    
      
      @whatsapp_templates=[]
      @email_templates=[]
      @sms_templates=[]

      
        WhatsappTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |whatsapp_template|
          @whatsapp_templates+=[whatsapp_template.title]
        end
        EmailTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |email_template|
          @email_templates+=[email_template.title]
        end
        SmsTemplate.where(business_unit_id: current_personnel.business_unit.id, live: true, inactive: nil).each do |sms_template|
          @sms_templates+=[sms_template.title]
        end

      
    
  end

  def sr_fresh_lead_entry
    Lead.transaction do
      @followup = FollowUp.new
      @followup.lead_id = TelephonyCall.find(params[:telephony_call_id].to_i).lead_id
      @lead = Lead.find(@followup.lead_id)
      if current_personnel.business_unit.organisation_id == 1
        if params[:followups] == [] || params[:followups] == nil
          if params[:whatsapp_templates] == [] ||  params[:whatsapp_templates] == nil
            if params[:email_tempaltes] == [] || params[:email_tempaltes] == nil
            else
              params[:email_templates].each do |email_template_id|
                email_template = EmailTemplate.find(email_template_id)
                email_data = [email_template.id, current_personnel.id, @lead.id]
                UserMailer.email_template_send(email_data).deliver

                template_send = TemplateSend.new
                template_send.template = email_template.title+' sent in Whatsapp'
                template_send.lead_id = @lead.id
                template_send.save
              end
            end
          else
            if params[:email_templates] == [] || params[:email_templates] == nil
            else
              params[:email_templates].each do |email_template_id|
                email_template = EmailTemplate.find(email_template_id)
                email_data = [email_template.id, current_personnel.id, @lead.id]
                UserMailer.email_template_send(email_data).deliver

                template_send = TemplateSend.new
                template_send.template = email_template.title+' sent in Whatsapp'
                template_send.lead_id = @lead.id
                template_send.save
              end
              params[:whatsapp_templates].each do |whatsapp_template_id|
                whatsapp_template = WhatsappTemplate.find(whatsapp_template_id)
                if (whatsapp_template.file_name == nil || whatsapp_template.file_name == '') && (whatsapp_template.file_url == nil || whatsapp_template.file_url == '')
                  urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                        result = HTTParty.post(urlstring,
                           :body => { :to_number => '+91'+(@lead.mobile),
                             :message => whatsapp_template.body,    
                              :type => "text"
                              }.to_json,
                              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
                      sleep(3)
                        urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                        result = HTTParty.post(urlstring,
                           :body => { :to_number => '+91'+(current_personnel.mobile),
                             :message => whatsapp_template.title+' sent to '+@lead.name,    
                              :type => "text"
                              }.to_json,
                              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
                        sleep(3)
                  template_send = TemplateSend.new
                  template_send.template = whatsapp_template.title+' sent in Whatsapp'
                  template_send.lead_id = @lead.id
                  template_send.save
                else
                  urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                        result = HTTParty.post(urlstring,
                           :body => { :to_number => '+91'+(@lead.mobile),
                             :message => whatsapp_template.file_url,    
                              :text => "",
                              :type => "media"
                              }.to_json,
                              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
                        sleep(3)
                        urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                        result = HTTParty.post(urlstring,
                           :body => { :to_number => '+91'+(current_personnel.mobile),
                             :message => whatsapp_template.title+' sent to '+@lead.name,    
                              :type => "text"
                              }.to_json,
                              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
                        sleep(3)
                  template_send = TemplateSend.new
                  template_send.template = whatsapp_template.title+' sent in Whatsapp'
                  template_send.lead_id = @lead.id
                  template_send.save
                end
                sleep(3)
              end
            end
          end
        else
          params[:followups].each do |followup_type|
            if followup_type == "Sms Followup"
              sms_followup = SmsFollowup.new
              sms_followup.lead_id = @lead.id
              sms_followup.save
              @picked_lead=@lead
              if @picked_lead.business_unit.walkthrough==nil || @picked_lead.business_unit.walkthrough==''
                number='91'+@picked_lead.mobile
                number=number.to_s
                  text="Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
                  text=text.to_s
                else
                number='91'+@picked_lead.mobile
                number=number.to_s
                number='91'+@picked_lead.mobile
                  text = "Thank you for your enquiry at " + @picked_lead.business_unit.name + " !! We tried calling you but could not reach you. Please let me know a good time to call you.%0aMeanwhile, please checkout our project walkthrough -%0a" + @picked_lead.business_unit.walkthrough + "%0a%0aRegards,%0a" + @picked_lead.personnel.name + "%0a" + @picked_lead.personnel.mobile + "%0a" + @picked_lead.personnel.email + "%0a"+@picked_lead.business_unit.organisation.name
                  text=text.to_s          
              end
                if @picked_lead.personnel.organisation.whatsapp_instance == nil
                  urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@picked_lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + number + "&text=" + text + "&route=03"
                response=HTTParty.get(urlstring)
              end
            end
            if followup_type == "Email Followup"
              if @lead.email == nil || @lead.email == ''
              else
                email_followup = EmailFollowup.new
                email_followup.lead_id = @lead.id
                email_followup.save
                data = @lead
                UserMailer.email_followup_to_lead(data).deliver
              end
            end
          end
        end
      end
      @followup.personnel_id = current_personnel.id
      @followup.communication_time = params[:leading][:flexible_date]
      @followup.follow_up_time = params[:leading][:followup_date]
      followup_hours = params[:leading]['followup_time(4i)'].to_i*60*60
      followup_minutes = params[:leading]['followup_time(5i)'].to_i*60
      @followup.follow_up_time = @followup.follow_up_time+followup_hours+followup_minutes
      @followup.remarks = params[:remarks]
      @followup.telephony_call_id = params[:telephony_call_id].to_i
      if params[:site_visit_feedback] == nil
      else
        @followup.feedback = params[:site_visit_feedback]
      end
      if params[:lead][:status]=='-1'
        if @lead.follow_ups.where(last: true)==[]
        else
          last_follow_up = @lead.follow_ups.where(last: true)[0]
          @followup.status = last_follow_up.status
          @followup.osv = last_follow_up.osv
        end
      elsif params[:lead][:status]=='0'
        if @lead.status==false
        else
          @lead.update(osv: nil)
          @followup.osv = nil 
        end
      elsif params[:lead][:status]=='1'
        @followup.osv = true
        @followup.status = nil
        if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
          @lead.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
        elsif @lead.qualified_on == nil
          @lead.update(osv: true, status: nil, qualified_on: params[:lead][:flexible_date])
        elsif @lead.interested_in_site_visit_on == nil
          @lead.update(osv: true, status: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
        else 
          @lead.update(osv: true, status: nil)
        end
        if @lead.visit_organised_on==nil
          @lead.update(visit_organised_on: Time.now)
        end
      elsif params[:lead][:status]=='2'
        if @lead.site_visited_on != nil
        else
          @lead.update(site_visited_on: Time.now)
          @number='91'+@lead.mobile
          @number=@number.to_s
          if @lead.business_unit.walkthrough!=nil
            @message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0aHeres our project walkthrough video.%0a" + @lead.business_unit.walkthrough + "%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
          else
            if @lead.business_unit.organisation.sender_id=='LABULB'
              @message="Thank you for meeting with us, hope you liked our demo. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"+@lead.business_unit.organisation.name
            else
              @message="Thank you for visiting " + @lead.business_unit.name + " !! Hope you liked our project. Please feel free to call us for any feedback or queries.%0a%0aRegards%0a" + @lead.personnel.name + "%0a" + @lead.personnel.mobile + "%0a"++@lead.business_unit.organisation.name
            end
          end 
          @message=@message.to_s
        #     urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+@lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + @number + "&text=" + @message + "&route=03"
          # response=HTTParty.get(urlstring)
        end 
        @followup.status=false
        @followup.osv=nil
        if @lead.qualified_on == nil && @lead.interested_in_site_visit_on == nil
          @lead.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date], interested_in_site_visit_on: params[:lead][:flexible_date])
        elsif @lead.qualified_on == nil
          @lead.update(status: false, osv: nil, qualified_on: params[:lead][:flexible_date])
        elsif @lead.interested_in_site_visit_on == nil
          @lead.update(status: false, osv: nil, interested_in_site_visit_on: params[:lead][:flexible_date])
        else
          @lead.update(status: false, osv: nil)
        end
        if @lead.visit_organised_on==nil
          @lead.update(visit_organised_on: Time.now)
        end
      elsif params[:lead][:status]=='3'
        @followup.osv=false
        @followup.status=nil
        @lead.update(osv: false, status: nil)
      elsif params[:lead][:status]=='5' 
        @followup.status=true
        @followup.osv=nil
        @lead.update(status: true, osv: nil)
        @lead.update(booked_on: params[:lead][:flexible_date])
        @lead.update(lost_reason_id: params[:lead][:lost_reason])
      elsif params[:lead][:status]=='4' 
        @followup.status=true
        @followup.osv=nil
        @lead.update(status: true, osv: nil)
        @lead.update(booked_on: params[:lead][:flexible_date])
      elsif params[:lead][:status]=='9'
        @followup.status = false
        @followup.osv = true
        if @lead.qualified_on==nil 
        @lead.update(osv: true, status: false, qualified_on: Time.now)
        else
        @lead.update(osv: true, status: false) 
        end
      elsif params[:lead][:status]=='10'
        @followup.status = false
        @followup.osv = true
        if @lead.interested_in_site_visit_on==nil
          if @lead.qualified_on == nil
            @lead.update(osv: true, status: false, qualified_on: Time.now, interested_in_site_visit_on: Time.now)
          else
            @lead.update(osv: true, status: false, interested_in_site_visit_on: Time.now)
          end
        else
          @lead.update(osv: true, status: false)
        end
      end
      @lead.update(escalated: nil, reengaged_on: nil)
      @lead.update(anticipation: params[:anticipation])
      if @lead.follow_ups != []
        @lead.follow_ups.each{|x| x.update(last: nil)}
        @followup.scheduled_time = @lead.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
      else
        @followup.first = true  
      end
      @followup.last = true
      @followup.save
    end
    TelephonyCall.find(params[:telephony_call_id].to_i).update(fresh: nil, untagged: nil)

    flash[:success] = "Lead Update Successfully."
    if params[:commit] == "Update Fresh Lead"
      redirect_to transaction_sr_fresh_leads_url
    elsif params[:commit] == "Update Live Lead"
      redirect_to transaction_sr_live_leads_url
    end
  end

  def sr_live_leads
    @telephony_calls = TelephonyCall.where(agent_number: current_personnel.mobile, fresh: nil, untagged: true)
    @telephony_calls += TelephonyCall.where(agent_number: current_personnel.mobile, fresh: false, untagged: true)
    executives = Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4)
    @executives=[]
    executives.each do |executive|
      @executives+=[[executive.name, executive.id]]
    end
    @executives.sort!
    @lost_reasons=selections(LostReason, :description)
    @common_followup_remarks = ['Not receiving the call', 'Switched off', 'Busy on another call', 'Number not reachable', 'Call Disconnected', 'Customer have not Enquired', 'Incoming Call facility is not available in this number', 'The customer have asked to call later', 'Invalid Number', 'Casual Enquiry', "Lead Rescheduled", "Lead transferred"]
  end

  def telecaller_lead_auditing
    @telecallers = []
    Personnel.where(organisation_id: 1, access_right: 2).each do |personnel|
      if personnel.name == "Tapan Samanta" || personnel.name == "Sudipta Debnath" || personnel.name == "Kazi Shahadat Hossain" || personnel.name == "Nitesh Maheshwari"
      else
        @telecallers += [[personnel.name, personnel.id]]
      end
    end
    if params[:personnel_id] == nil
      @executive = current_personnel
      @from = DateTime.now-8.days
      @to = DateTime.now-1.day
      @telephony_calls = []
      @duration = ''
    else
      @executive = Personnel.find(params[:personnel_id].to_i)
      @from = params[:from].to_datetime.beginning_of_day
      @to = params[:to].to_datetime
      @duration = params[:duration]
      if @duration == "Less than 30 sec"
        @telephony_calls = TelephonyCall.where.not(lead_id: nil).where('agent_number = ? AND created_at >= ? AND created_at < ? AND duration <= ?', @executive.mobile, @from, @to.beginning_of_day+1.day, 30.0).sort_by{|x| x.lead_id}
      elsif @duration == "Greater than 30 sec"
        @telephony_calls = TelephonyCall.where.not(lead_id: nil).where('agent_number = ? AND created_at >= ? AND created_at < ? AND duration > ?', @executive.mobile, @from, @to.beginning_of_day+1.day, 30.0).sort_by{|x| x.lead_id}
      elsif @duration == "Any Duration"
        @telephony_calls = TelephonyCall.where.not(lead_id: nil).where('agent_number = ? AND created_at >= ? AND created_at < ?', @executive.mobile, @from, @to.beginning_of_day+1.day).sort_by{|x| x.lead_id}
      end
    end
  end

  def live_lead_whatsapp
    @executives = []
     Personnel.where(organisation_id: 1).where('access_right is ? OR access_right = ? ', nil, 2 ).each do |personnel|
      if personnel.name == "Tapan Samanta" || personnel.name == "Sudipta Debnath" || personnel.name == "Kazi Shahadat Hossain" || personnel.name == "Nitesh Maheshwari"
      else
        @executives += [[personnel.name, personnel.id]]
      end
    end
    if params[:personnel_id] == nil && params[:data] == nil
      # @executive_selected = -1
      # @leads = []
    else
      if params[:data] == nil && params[:personnel_id] != nil
        @leads = []
        Lead.where(personnel_id: params[:personnel_id], business_unit_id: 70, lost_reason_id: nil).each do |lead|
          @leads += [[lead.id, lead.name, lead.unseen_messages]]
        end
        @leads = @leads.sort_by{|_,_,x| x}.reverse
        @selected_lead = nil
      else
        @selected_lead = Lead.find(params[:data][:lead_id])
        @leads = []
        Lead.where(personnel_id: params[:data][:personnel_id], business_unit_id: 70, lost_reason_id: nil).each do |lead|
          @leads += [[lead.id, lead.name, lead.unseen_messages]]
        end
        @leads = @leads.sort_by{|_,_,x| x}.reverse
        if current_personnel.email == "ayush@thejaingroup.com"
        else
          @selected_lead.whatsapp_message_seen
        end
      end
    end
  end

  def whatsapp_to_lead
    lead = Lead.find(params[:lead_id])
    reply = params[:reply_to_customer]
    urlstring = "https://graph.facebook.com/v17.0/132619236591729/messages"
    result = HTTParty.post(urlstring,
    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": lead.mobile.to_s, "type": "text", "text": {"preview_url": false, "body" => reply.to_s}}.to_json,
    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
    p result
    p "===================="
    message_data = result.parsed_response
    message_id = message_data["messages"]
    message_id = message_id[0]["id"]
    whatsapp_followup = WhatsappFollowup.new
    whatsapp_followup.lead_id = lead.id
    whatsapp_followup.bot_message = reply.to_s
    whatsapp_followup.message_id = message_id
    whatsapp_followup.save
    redirect_to :back
  end
end