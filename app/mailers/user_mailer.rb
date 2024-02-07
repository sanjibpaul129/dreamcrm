class UserMailer < ApplicationMailer
default from: 'system.admin@thejaingroup.com',
parts_order: ['text/plain','text/enriched','text/x-amp-html','text/html']

    def gurukul_email_template
        p "working"
        mail :to => 'sanjibpaul12012000@gmail.com', :subject => 'On Lead creation'
    end

    def sv_feedback_link_send(data)
        @lead = data[0]
        mail :to => @lead.email, :bcc => 'system1@thejaingroup.com, sanjibpaul12012000@gmail.com', :subject => 'Site Visit Feedback'

        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
        result = HTTParty.post(urlstring,
        :body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+@lead.mobile.to_s,"type": "template","template": {"name": "gurukul_sv_feedback","language": {"code": "en"},"components": [
            {"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=62CE802EFF85EB45%21254&authkey=%21AMDrfZkutxi8QvI&width=940&height=788"}}]},
            {"type": "body","parameters": [{"type": "text","text": @lead.name.to_s}]},
            {"type": "button", "sub_type": "flow" ,"index": "1", "parameters": [{"type": "text", "text": "Share Your Feedback"}]}
            ]}}.to_json,
        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
        p result
        p "======================================="
    end

    def signed_broker_data_mail(data)
        @broker_contact = data[0]
        mail :to => 'system1@thejaingroup.com, system.admin@thejaingroup.com, saikatmanna112@gmail.com', :subject => 'Signed broker data'
    end
    
    def followup_frequency_check(data)
        @telecaller_wise_data = data
        mail :to => 'system1@thejaingroup.com', :subject => 'Followup Frequency Report'
    end

    def fresh_lead_intimation_alert(data)
        @broker_contact = BrokerContact.find(data[0].to_i)
        @business_unit = BusinessUnit.find(data[1].to_i)
        @name = data[2]
        @email = data[3]
        @mobile = data[4]
        if @broker_contact.email == nil || @broker_contact.email == ""
        else
            mail :to => @broker_contact.email, :cc => 'system1@thejaingroup.com, saikatmanna112@gmail.com, system.admin@thejaingroup.com', :subject => 'Fresh Lead Intemation'
        end
    end

    def lead_intimation_found(data)
        @leads = data[0]
        @type = data[1]
        @broker_contact = BrokerContact.find(data[2].to_i)
        @business_unit = BusinessUnit.find(data[3].to_i)
        @name = data[4]
        @email = data[5]
        @mobile = data[6]
        if data[1] == "Lost Leads found"
            # internal alert
            if @broker_contact.email == nil || @broker_contact.email == ""
            else
                mail :to => "system.admin@thejaingroup.com", :cc => 'system1@thejaingroup.com, saikatmanna112@gmail.com', :subject => 'Lost Lead Existance Found'
            end
        elsif data[1] == "Live Leads found"
            # all alert
            if @broker_contact.email == nil || @broker_contact.email == ""
            else
                mail :to => @broker_contact.email, :cc => 'system1@thejaingroup.com, system.admin@thejaingroup.com, saikatmanna112@gmail.com', :subject => 'Live Lead Existance Found'
            end
        elsif data[1] == "Intimation found"
            # internal alert
            if @broker_contact.email == nil || @broker_contact.email == ""
            else
                mail :to => "system.admin@thejaingroup.com", :cc => 'system1@thejaingroup.com, saikatmanna112@gmail.com', :subject => 'Broker Lead Intimation Found'
            end
        end
    end

    def customer_whatsapp(data)
        @customer_name = data[0]
        @customer_number = data[1]
        @customer_message = data[2]
        @whatsapp_number = data[3]
        @broker_contact = data[4]
        if @broker_contact.personnel_id == nil
            mail :to => 'system1@thejaingroup.com', :subject => 'Broker Reply'
        else
            mail :to => @broker_contact.personnel.email, :bcc => 'system1@thejaingroup.com, saikatmanna112@gmail.com', :subject => 'Broker Reply'
        end
    end
    def lead_whatsapp(data)
        @customer_name = data[0]
        @customer_number = data[1]
        @customer_message = data[2]
        @whatsapp_number = data[3]
        @lead = data[4]
        if @lead.personnel_id == nil
            mail :to => 'system1@thejaingroup.com, aniketkrbiswas239@gmail.com', :subject => 'Lead Reply'
        else
            mail :to => @lead.personnel.email, :bcc => 'system1@thejaingroup.com, aniketkrbiswas239@gmail.com', :subject => 'Lead Reply'
        end
    end

    def sending_whatsapp_to_customer(data)
        @customer_number = data[0]
        @whatsapp_number = data[1]
        @reply = data[2]
        mail :to => 'system1@thejaingroup.com, saikatmanna112@gmail.com', :subject => 'whatsapp reply to Broker'
    end

    def broker_agreement_mail(data)
        @broker = data[0]
        @broker_contact = data[2]
        mail.attachments['Agreement.pdf']={mime_type: 'application/pdf', content: data[1] }
        mail :to => @broker_contact.email, :bcc => 'system1@thejaingroup.com', :subject => 'Channel Partner Contract'
    end

    def broker_contact_data_mail(data)
        @broker_contact = BrokerContact.find(data[0].to_i)
        @personnel = Personnel.where(mobile: data[1], access_right: 2, expanded: true)[0]
        @customer_number = data[2]
        if @personnel == nil
        else
            mail :to => @personnel.email, :subject => 'Broker Incoming Call Details'
        end
    end

 def site_visit_feedback(data)
    @lead = data[0]
    p @lead
    p "============================="
    if @lead.email == nil
    else
        p "inserting into the email section"
        p "================"
        mail(to: 'system1@thejaingroup.com', subject: 'Testing AMP Email!') do |format|
          format.text
          format.html
          format.amp
        end
        # mail :to => 'system1@thejaingroup.com', :subject => 'Feedback Form'
        # mail :to => @lead.email, :subject => 'Feedback Form'
    end

    
 end

def missed_telephony_call(data)
    @followup_id = data[0]
    @telephony_call = data[1]
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com, ayushruia1@gmail.com', :subject => 'missed telephony call'
end


def lead_details(data)
    @leads = data
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com', :subject => 'doh lead details'
end

def daily_aag(data)
    @source_tree = data[0]
    @from=data[2]
    @to=data[3]
    @business_unit_id=data[4]
    mail.attachments['Daily Report.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail :from => 'notifications@trackenquiry.com', :to => 'ayushruia1@gmail.com', :subject => 'Daily Report'
end

def push_api_testing(data)
    @all_params = data
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com', :subject => 'push api testing'
end

def referred_leads_status(data)
    @all_leads=data[0]
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com', :subject => 'Referred Lead Status'
end
def introductory(data)
    @customer_email = data[0]
    @email_template=data[1]

    mail :from => 'notifications@trackenquiry.com', :to => @customer_email, :subject => "Introductory"
end

def birthday_wish(data)
    @customer_email = data[0]
    @organisation_id=data[1]
    @email_template= EmailTemplate.where(organisation_id: @organisation_id.to_i, birthday_wish: true, inactive: nil)[0]
    if @email_template != nil
    mail :from => Organisation.find(@organisation_id.to_i).email, :to => @customer_email, :subject => "Birthday Wish"
    end
end

def send_booking_form(data)
    booking_id = data[0]
    @booking = Booking.find(booking_id.to_i)
    @current_personnel = data[2]
    mail.attachments['Booking Form.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakmca11132@gmail.com', :subject => "Booking Form"
end

def send_allotment_letter(data)
    booking_id = data[0]
    @booking = Booking.find(booking_id.to_i)
    @current_personnel = data[2]
    mail.attachments['Allotment Letter.pdf']={mime_type: 'application/pdf', content: data[1] }
    if @booking.cost_sheet.lead.email == nil || @booking.cost_sheet.lead.email == ''
    else
        mail :from => @current_personnel.email, :to => @booking.cost_sheet.lead.email, :subject => "Allotment Letter"
    end
end

def bungalow_snippet(data)
    personnel = data[0]
    mail.attachments['Bungalow No. '+(data[2].floor.to_s)+' Cost Breakup.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail :from => 'notifications@trackenquiry.com', :to => personnel.email, :bcc => 'ayush@tracemydoc.com', :subject => ('Bungalow No. '+(data[2].floor.to_s)+' Cost Breakup')
end

def bungalow_snippet_area(data)
    personnel = data[0]
    mail.attachments['Bungalow No. '+(data[2].floor.to_s)+' Area Details.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail :from => 'notifications@trackenquiry.com', :to => personnel.email, :bcc => 'ayush@tracemydoc.com', :subject => ('Bungalow No. '+(data[2].floor.to_s)+' Area Details')
end

def send_mortgage_noc(data)
    booking_id = data[0]
    @booking = Booking.find(booking_id.to_i)
    @current_personnel = data[2]
    mail.attachments['Mortgage NOC.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakmca11132@gmail.com', :subject => "Mortgage-NOC"
end

def anniversary_wish(data)
    @customer_email = data[0]
    @organisation_id=data[1]
    @email_template= EmailTemplate.where(organisation_id: @organisation_id.to_i, anniversary_wish: true, inactive: nil)[0]
    if @email_template != nil
    mail :from => Organisation.find(@organisation_id.to_i).email, :to => @customer_email, :subject => "Anniversary Wish"
    end
end

def email_template_send(data)
    require 'open-uri'
    email_template_id=data[0]
    @email_template=EmailTemplate.find(email_template_id.to_i)
    current_personnel_id=data[1]
    @current_personnel=Personnel.find(current_personnel_id.to_i)
    lead_id=data[2]
    @lead=Lead.find(lead_id.to_i)
    @email_template.email_attachments.each do |email_attachment|
        mail.attachments[email_attachment.data_file_name]=open('https:'+email_attachment.data.url).read
    end
    mail :from => @current_personnel.email, :to => @lead.email, :cc => @current_personnel.email, :subject => @email_template.title
end

def second_welcome_letter(data)
    @booking=data[0]
    @milestone_amount=data[3]
    mail.attachments['money_receipt.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail.attachments['cost_sheet.pdf']={mime_type: 'application/pdf', content: data[2] }
    if @booking.cost_sheet.lead.email == nil || @booking.cost_sheet.lead.email == ''
    else
        @email=@booking.cost_sheet.lead.email
        mail :from => 'notifications@trackenquiry.com', :to => @email, :subject => "Welcome To "+@booking.cost_sheet.flat.block.business_unit.name 
    end
end

def password_reset(user)
    @user = user
    mail :from => 'notifications@trackenquiry.com', :to => user.email, :subject => "Password Reset"
end

def ad_hoc(data)
    @data = data
    mail :from => 'notifications@trackenquiry.com', :to => 'ayush@thejaingroup.com', :subject => "Ad hoc"
end

def lead_export(data)
    @data = data
    mail :from => 'notifications@trackenquiry.com', :to => 'ayush@erpbuddy.com, rsoumyo@rajathomes.com', :subject => "Lead Export"
end

def daily_sales_report(data)
@project_wise_leads_generated=data[0]
@source_wise_leads_generated=data[1]
@site_visits=data[2]
@bookings=data[3]
mail :from => 'notifications@trackenquiry.com', :to => 'soumya@thejaingroup.com, nakhyastra@thejaingroup.com', :cc => 'ayush@thejaingroup.com, paramita@thejaingroup.com', :subject => "Daily Sales Report"
end

def email_followup_to_lead(data)
    require 'open-uri'
    @picked_lead=data
    if @picked_lead.personnel.organisation.name=='Jain Group'
    attachments.inline['jg_mail.jpg'] = File.read(Rails.root + 'app/assets/images/jg_mail.jpg')
    elsif @picked_lead.business_unit.name=='Orchard 126'
    mail.attachments['Orchard 126 Flyer.pdf']=File.read(Rails.root + 'app/assets/images/orchard_126.pdf')
    elsif @picked_lead.business_unit.name=='Serene Tower'
    attachments.inline['SereneTower.jpg']=open('https://imageclassify.s3.amazonaws.com/JSB+Serene+Tower.jpg').read
    attachments.inline['serene_logo.png']=open('https://imageclassify.s3.amazonaws.com/Serene-logo.png').read
    elsif @picked_lead.business_unit.name=='Jyoti Residency'    
    attachments.inline['JyotiResidency.jpg']=open('https://imageclassify.s3.amazonaws.com/Jyoti+Residency+Creative.jpg').read
    attachments.inline['jyoti-logo.png']=open('https://imageclassify.s3.amazonaws.com/jyoti-logo.png').read
    end
    if @picked_lead.personnel.predecessor == nil
        @bcc_to = @picked_lead.personnel.email.strip
    else
        @bcc_to = @picked_lead.personnel.email.strip + ',' + Personnel.find(@picked_lead.personnel.predecessor).email.strip
    end
    @bcc_to+=''
    mail :from => @picked_lead.personnel.email.strip, :to => @picked_lead.email.strip, :bcc => @bcc_to, :subject => "Thanks for your Enquiry"
end

def welcome_letter(data)
    @cost_sheet_id=data[0]
    @current_personnel = data[1]
    @cost_sheet=CostSheet.find_by_id(@cost_sheet_id.to_i)

    mail.attachments['Welcome Letter.pdf']={mime_type: 'application/pdf', content: data[2] }
    if @cost_sheet.lead.email == nil || @cost_sheet.lead.email == ''
    else
        mail :from => @current_personnel.email, :to => @cost_sheet.lead.email, cc: @current_personnel.email,:bcc => 'dipakmca11132@gmail.com',:subject => "Welcome To "+@cost_sheet.flat.block.business_unit.name 
    end
end

def unattended_fresh_leads(data)
    @fresh_leads = data
    if @fresh_leads[0].personnel.predecessor != nil
    team_lead_email=Personnel.find(@fresh_leads[0].personnel.predecessor).email.strip
    mail_to='paramita@thejaingroup.com'+','+@fresh_leads[0].personnel.email.strip+','+team_lead_email.strip
    else
    mail_to='paramita@thejaingroup.com'+','+@fresh_leads[0].personnel.email.strip
    end
    mail :from => @fresh_leads[0].personnel.organisation.email, :to => mail_to, :subject => "Unattended Fresh Leads"
end

def low_escalated_fresh_leads(data)
    @cc=''
    @data = data
    executive_mail=@data[0].personnel.email.strip
        if @data[0].personnel.predecessor!=nil
        team_lead_mail=Personnel.find(@data[0].personnel.predecessor).email.strip
            if data[0].business_unit.organisation.name=='Jain Group'
            to=executive_mail+','+team_lead_mail
            else
            to=executive_mail+','+team_lead_mail    
            end
        else
        to=executive_mail
        end
    if data[0].business_unit.organisation.name=='Jain Group'
    @cc+='chanchal@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com'
    elsif data[0].business_unit.organisation.name=='Oswal Group'
    @cc+='customercare@oswalgroup.net'
    elsif data[0].business_unit.organisation.name=='Rajat Group'
    @cc+=''
    end
    
    if to=='tausif@alcoverealty.in' || to=='shashank@thejaingroup.com' || to=='tanusree@thejaingroup.com'
    else
    mail :from => @data[0].personnel.organisation.email, :to => to, :cc => @cc, :subject => "Fresh Lead Escalated"
    end
end

def high_escalated_fresh_leads(data)
    @cc=''
    @data = data
    executive_mail=@data[0].personnel.email.strip
        if @data[0].personnel.predecessor!=nil
        team_lead_mail=Personnel.find(@data[0].personnel.predecessor).email.strip
            if data[0].business_unit.organisation.name=='Jain Group'
            to=executive_mail+','+team_lead_mail
            else
            to=executive_mail+','+team_lead_mail    
            end
        else
        to=executive_mail
        end
    if data[0].business_unit.organisation.name=='Jain Group'
    @cc+='chanchal@thejaingroup.com, rishi@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com'
    elsif data[0].business_unit.organisation.name=='Oswal Group'
    @cc+='customercare@oswalgroup.net'
    elsif data[0].business_unit.organisation.name=='Rajat Group'
    @cc+=''
    elsif data[0].business_unit.organisation.name=='JSB Infrastructures'
    @cc+='nikunj@jsb.in.net'
    end
    
    if to=='tausif@alcoverealty.in' || to=='tanusree@thejaingroup.com'
    else
    mail :from => @data[0].personnel.organisation.email, :to => to, :cc => @cc, :subject => "Fresh Escalated High"
    end
    
end

def followup_today(data)
    @followups = data
    mail :from => data[0].personnel.organisation.email, :to => @followups[0].personnel.email.strip, :subject => "Followup today"
end

def escalate(data)
    @followups = data
    mail :from => data[0].personnel.organisation.email, :to => @followups[0].personnel.email.strip, :cc => 'rishi@thejaingroup.com, nakhyastra@thejaingroup.com, chanchal@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com', :subject => "Followups pending escalated"
end

def escalate_low(data)
	
    @followups = data
    
    if @followups[0].lead.business_unit_id==3 || @followups[0].lead.business_unit_id==1 || @followups[0].lead.business_unit_id==4 || @followups[0].lead.business_unit_id==5
    @cc='chanchal@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com'
    elsif @followups[0].lead.business_unit_id==2 || @followups[0].lead.business_unit_id==8 || @followups[0].lead.business_unit_id==7 || @followups[0].lead.business_unit_id==6
    @cc='nakhyastra@thejaingroup.com, chanchal@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com'
    elsif @followups[0].lead.business_unit.organisation.name=='Rajat Group'
    @cc='rsoumyo@rajathomes.com'
    else
    @cc='ayush@tracemydoc.com'	
    end
    if data[0].lead.business_unit.organisation.name=='Jain Group'
    elsif data[0].lead.business_unit.organisation.name=='Oswal Group'
    @cc+=',customercare@oswalgroup.net'
    end
    if @followups[0].personnel.email == 'arnabmallick@thejaingroup.com' || @followups[0].personnel.email == 'subijit@thejaingroup.com' || @followups[0].personnel.email == 'anant@thejaingroup.com' || @followups[0].personnel.email == 'tausif@alcoverealty.in' || @followups[0].personnel.email == 'sales@jsb.in.net' || @followups[0].personnel.email == 'manish@jsb.in.net' || @followups[0].personnel.email=='shashank@thejaingroup.com' || @followups[0].lead.personnel.email=='tanusree@thejaingroup.com'
    else
    mail :from => data[0].personnel.organisation.email, :to => @followups[0].lead.personnel.email.strip, :cc => @cc, :bcc => 'ayush@tracemydoc.com', :subject => "Followups pending escalated"
    end 
end

def escalate_high(data)
    @followups = data[0]+data[1]
    @new_count=data[0].count

    if @followups[0].lead.business_unit_id==3 || @followups[0].lead.business_unit_id==1 || @followups[0].lead.business_unit_id==4 || @followups[0].lead.business_unit_id==5
    @cc='rishi@thejaingroup.com, chanchal@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com'
    elsif @followups[0].lead.business_unit_id==2 || @followups[0].lead.business_unit_id==8 || @followups[0].lead.business_unit_id==7 || @followups[0].lead.business_unit_id==6
    @cc='rishi@thejaingroup.com, chanchal@thejaingroup.com, nakhyastra@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com'
    else
        if data[0].lead.business_unit.organisation.name=='Jain Group'
        @cc='rishi@thejaingroup.com, hr@thejaingroup.com, jaingroupcaller3@thejaingroup.com'
        elsif data[0].lead.business_unit.organisation.name=='Oswal Group'
        @cc='customercare@oswalgroup.net'
        elsif data[0].lead.business_unit.organisation.name=='Rajat Group'
        @cc='rsoumyo@rajathomes.com'
    elsif data[0].lead.business_unit.organisation.name=='JSB Infrastructures'
        @cc='nikunj@jsb.in.net'
        end
    end
       if data[0].lead.business_unit.organisation.name=='Jain Group'
       @cc+=''
       elsif data[0].lead.business_unit.organisation.name=='Oswal Group'
       @cc+=''
       end 
    
    if @followups[0].personnel.email == 'arnabmallick@thejaingroup.com' || @followups[0].personnel.email == 'subijit@thejaingroup.com' || @followups[0].personnel.email == 'anant@thejaingroup.com' || @followups[0].personnel.email == 'tanusree@thejaingroup.com' || @followups[0].personnel.email == 'tausif@alcoverealty.in'
    else
    mail :from => data[0].lead.business_unit.organisation.email, :to => @followups[0].lead.personnel.email.strip, :cc => @cc, :bcc => 'ayush@tracemydoc.com' , :subject => "Followups pending escalated to ED"
    end
end

def api_testing(data)
    @data = data
    if @data[0]=='highrise_alcove_data'
    mail :from => 'notifications@trackenquiry.com', :to => 'ayush@tracemydoc.com,tausif@alcoverealty.in', :subject => @data[1]
    else
    mail :from => 'notifications@trackenquiry.com', :to => 'ayush@tracemydoc.com,ayushruia1@gmail.com', :subject => @data[1]
    end
end

def whatsapp_site_visit(data)
    @data = data
    mail :from => 'notifications@trackenquiry.com', :to => 'ayush@tracemydoc.com,tausif@alcoverealty.in', :subject => 'Whatsapp Site Visit'
end

def detect_lead(lead_details)
    @lead_details = lead_details
    mail :from => 'notifications@trackenquiry.com', :to => 'ayush_ruia@hotmail.com', :subject => "Lead details"
end

def lead_import_errors(data)
    @errors = data[0]
    @leads_imported=data[1]
    business_unit=nil
    @errors.each do |error|
       if business_unit==nil 
       business_unit=BusinessUnit.find_by_name(error[1]['Project_Name'])
       end
    end
    if business_unit==nil
        business_unit=BusinessUnit.find(data[2].try(:business_unit_id))
    end
    if business_unit==nil
    mail :from => 'notifications@trackenquiry.com', :to => 'ayushruia1@gmail.com', :subject => "Lead Import Errors("+@errors.count.to_s+")"
    elsif business_unit.organisation.name=='Jain Group'
    mail :from => business_unit.organisation.email, :to => 'ayushruia1@gmail.com', :subject => "Lead Import Errors("+@errors.count.to_s+")"
    elsif business_unit.organisation.name=='Oswal Group'
    mail :from => business_unit.organisation.email, :to => 'customercare@oswalgroup.net', :subject => "Lead Import Errors("+@errors.count.to_s+")"
    else
    mail :from => 'notifications@trackenquiry.com', :to => 'ayushruia1@gmail.com', :subject => "Lead Import Errors("+@errors.count.to_s+")"
    end
end

def qualified_lead_import_errors(data)
    @rows = data[0]
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com, socialmedia@thejaingroup.com', :subject => "Qualified Lead Import Errors"
end

def site_visited_lead_import_errors(data)
    @rows = data[0]
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com, socialmedia@thejaingroup.com', :subject => "site_visited Lead Import Errors"
end

def api_testing_other(data)
    @data = data
    cc='ayushruia1@gmail.com'
    if Organisation.find_by_name(@data[2]) != nil
        if @data[2]=='JSB Infrastructures'
            cc='ayushruia1@gmail.com'
        elsif @data[2]=='Rajat Group'
            cc='ayushruia1@gmail.com'
        else 
            cc=Personnel.where(access_right: 0, organisation_id: Organisation.find_by_name(@data[2]).id)[0].email
        end
    end
    if data[6]=='Dream One'
    cc='nakhyastra@thejaingroup.com'
    elsif Organisation.find_by_name(@data[2]) != nil
        if @data[2]=='Jain Group' && data[6]!='Dream One'
            cc='chanchal@thejaingroup.com'
        end
    end    
    mail :from => 'notifications@trackenquiry.com', :to => 'ayushruia1@gmail.com', :cc => cc, :subject => @data[0]
end

def new_lead_notification(lead)
    p lead
    p "============"
    @lead = lead
    p @lead
    p "===============lead data==============="
    if lead.business_unit.organisation.name=='Jain Group'
        mail :from => lead.business_unit.organisation.email, :to => lead.personnel.email, :subject => "New Lead Notification"
    elsif lead.business_unit.organisation.name=='Oswal Group'
    mail :from => lead.business_unit.organisation.email, :to => lead.personnel.email, :cc => 'customercare@oswalgroup.net', :subject => "New Lead Notification"
    elsif lead.business_unit.organisation.name=='JSB Infrastructures'
    # mail :from => lead.business_unit.organisation.email, :to => 'ayushruia1@gmail.com', :subject => "New Lead Notification"
    elsif lead.business_unit.organisation.name=='Rajat Group'
    # mail :from => lead.business_unit.organisation.email, :to => 'ayushruia1@gmail.com', :bcc => 'ayush@tracemydoc.com', :subject => "New Lead Notification"
    end
end

def field_visit_escalation(data)
    @executive=data[0]
    @leads_generated=data[1]
    @field_visits=data[2]
    @field_visit_percentage=data[3]
    if @executive.organisation.name=='Jain Group'
    mail :from => data[0].organisation.email, :to => data[0].email, :cc => 'nakhyastra@thejaingroup.com, soumya@thejaingroup.com', :subject => "Field Visit Escalated"
    elsif @executive.organisation.name=='Oswal Group'
    mail :from => data[0].organisation.email, :to => data[0].email, :cc => 'customercare@oswalgroup.net, ayush@tracemydoc.com', :subject => "Field Visit Escalated"
    end
end


def cost_sheet_to_customer(data)
    @lead=Lead.find(data[1])
    mail.attachments['Cost Sheet.pdf']={mime_type: 'application/pdf', content: data[0] }
    if @lead.email=='' || @lead.email==nil
    else
        if @lead.business_unit.organisation.name=='Jain Group'
        mail :from => @lead.personnel.email, :to => @lead.email, :cc => 'pallabita@thejaingroup.com,'+@lead.personnel.email, :bcc => 'ayush@tracemydoc.com', :subject => "Cost Sheet"
        elsif @lead.business_unit.organisation.name=='JSB Infrastructures'
        mail :from => @lead.personnel.email, :to => @lead.email, :cc => 'sumit@jsb.in.net,'+@lead.personnel.email, :bcc => 'ayush@tracemydoc.com', :subject => "Cost Sheet"
        elsif @lead.business_unit.organisation.name=='Oswal Group'
        mail :from => @lead.business_unit.organisation.email, :to => @lead.personnel.email, :cc => 'customercare@oswalgroup.net, ayush@tracemydoc.com', :bcc => 'ayushruia1@gmail.com', :subject => "Cost Sheet"
        end
    end
end

def maintainance_bill(data)
    maintenance_bill=data[1]
    @lead=Lead.find(maintenance_bill.lead_id)
    @flat=Flat.find(maintenance_bill.flat_id)
    mail.attachments['maintainance bill.pdf']={mime_type: 'application/pdf', content: data[0] }
    if @lead.email==nil
    else
        mail :from => 'rupsa@thejaingroup.com', :to => @lead.email, :cc => 'bidesh@thejaingroup.com, rupsa@thejaingroup.com, suvrajyoti@thejaingroup.com', :subject => "Maintainance Bill"
    end
end

def send_demand(data)
    @ledger_entry_header=LedgerEntryHeader.find(data[0].to_i)
    @current_personnel=data[2]
    email=LedgerEntryHeader.find(data[0].to_i).booking.cost_sheet.lead.email
    mail.attachments['demand.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail :from => data[2].email, :to => email, :bcc => data[2].email, :subject => "Demand Letter"
end

def send_demand_money_receipt(data)
    @current_personnel = data[2]
    @demand_money_receipt = DemandMoneyReceipt.find(data[0].to_i)
    
    mail.attachments['Demand MoneyReceipt.pdf']={mime_type: 'application/pdf', content: data[1] }
    if @demand_money_receipt.booking.cost_sheet.lead.email == nil || @demand_money_receipt.booking.cost_sheet.lead.email == ''
    else
        mail :from => @current_personnel.email, :to => @demand_money_receipt.booking.cost_sheet.lead.email, :bcc => data[2], :subject => "Money Receipt"
    end
end

def money_receipt(data)
    money_receipt=data[1]
    # money_receipt=MoneyReceipt.find(money_receipt_id.to_i)
    @lead=Lead.find(money_receipt.lead_id)
    @flat=Flat.find(money_receipt.flat_id)
    mail.attachments['money_receipt.pdf']={mime_type: 'application/pdf', content: data[0] }
    if @lead.email==nil
    else
        mail :from => 'rupsa@thejaingroup.com', :to => @lead.email, :cc => 'bidesh@thejaingroup.com, rupsa@thejaingroup.com, suvrajyoti@thejaingroup.com', :subject => "Money Receipt"
    end
end

def bulk_outstanding_reminder(data)
    @flat=data
    @lead = Lead.find(@flat.lead_id)
    @maintainance_bills = MaintainenceBill.where(flat_id: @flat.id.to_i)
    @money_receipts = MoneyReceipt.where(flat_id: @flat.id.to_i)
    @maintenance_credit_notes = MaintenanceCreditNoteEntry.where(lead_id: Flat.find(@flat.id).lead_id)
    @both_documents = @maintainance_bills+@money_receipts+@maintenance_credit_notes
    @both_documents = @both_documents.sort_by{|document| document.date}
    
    attachments.inline['palanhare qrcode.jpg'] = File.read(Rails.root + 'app/assets/images/palanhare qrcode.jpg')
    mail :from => 'rupsa@thejaingroup.com', :to => @lead.email, cc: 'bidesh@thejaingroup.com, rupsa@thejaingroup.com', :subject => "Outstanding Reminder"
end

def bulk_electrical_outstanding_reminder(data)
    @flat=data
    @lead = Lead.find(@flat.lead_id)
    attachments.inline['palanhare qrcode.jpg'] = File.read(Rails.root + 'app/assets/images/palanhare qrcode.jpg')
    mail :from => 'rupsa@thejaingroup.com', :to => @lead.email, cc: 'bidesh@thejaingroup.com', :subject => "Electrical Outstanding Reminder" 
end

def demand_outstanding_reminder(data)
    @current_personnel=data[0]
    @booking=data[1]
    @lead=Lead.find(@booking.cost_sheet.lead_id)
    attachments.inline['jg_mail.jpg'] = File.read(Rails.root + 'app/assets/images/jg_mail.jpg')
    mail :from => @current_personnel.email, :to => @lead.email, :bcc => @current_personnel.email, :subject => "Demand Outstanding Reminder" 
end

def electrical_bill(data)
    @lead=Lead.find(data[1].lead_id)
    @flat=Flat.find(data[1].flat_id)
    mail.attachments['electric bill.pdf']={mime_type: 'application/pdf', content: data[0] }
    if @lead.email==nil
    else
        mail :from => 'rupsa@thejaingroup.com', :to => @lead.email, :cc => 'bidesh@thejaingroup.com, rupsa@thejaingroup.com, suvrajyoti@thejaingroup.com', :subject => "Electric Bill"
    end
end

def electrical_money_receipt(data)
    @lead=Lead.find(data[1].lead_id)
    @flat=Flat.find(data[1].flat_id)
    mail.attachments['money_receipt.pdf']={mime_type: 'application/pdf', content: data[0] }
    if @lead.email==nil
    else
        mail :from => 'rupsa@thejaingroup.com', :to => @lead.email, :cc => 'bidesh@thejaingroup.com, rupsa@thejaingroup.com, suvrajyoti@thejaingroup.com', :subject => "Money Receipt"
    end
end

def demand_ledger(data)
    @current_personnel=data[2]
    @booking=Booking.find_by_id(data[1])
    mail.attachments['Applicant Ledger.pdf']={mime_type: 'application/pdf', content: data[0] }
    if @booking.cost_sheet.lead.email==nil
    else
        mail :from => @current_personnel.email, :to => @booking.cost_sheet.lead.email, :bcc => @current_personnel.email, :subject => "Applicant ledger"
    end 
end

def em_report(data)
    @fresh_leads=data[0]
    @fresh_calls=data[1]
    @personnel_site_visits=data[2]
    @bookings=data[3]
    @site_executives=data[4]
    @site_visits_organised=data[5]
    @site_visits_received=data[6]
    mail :from => 'notifications@trackenquiry.com', :to => 'ayush@erpbuddy.com, rupasharma@thejaingroup.com', :subject => "EM Report"
end

def all_lead_export(data)
    all_lead_export=data[0]
    @leads=data[1]
    mail :from => 'notifications@trackenquiry.com', :to => @leads[0].business_unit.organisation.email, :to => all_lead_export.email, :subject => "Lead Bulk Export" 
end

def testing_email_send(data)
    require 'open-uri'
    email_id=data[0]
    email_template_id=data[1]
    personnel_id=data[2]
    @personnel=Personnel.find_by_id(personnel_id.to_i)
    @email_template=EmailTemplate.find_by_id(email_template_id.to_i)
    @email_template.email_attachments.each do |email_attachment|
        mail.attachments[email_attachment.data_file_name]=open('https:'+email_attachment.data.url).read
    end
    mail :from => @personnel.email, :to => email_id, :bcc => @personnel.email, :subject => @email_template.title    
end

def credit_note(data)
    @credit_note=data[1]
    @lead=Lead.find(@credit_note.lead_id)
    if @lead.email == '' || @lead.email == nil
    else
        mail.attachments['credit_note.pdf']={mime_type: 'application/pdf', content: data[0] }
        mail :from => 'rupsa@thejaingroup.com', :to => @lead.email, :cc => 'bidesh@thejaingroup.com', :bcc => 'rupsa@thejaingroup.com', :subject => "Credit Note"
    end
end

def send_agreement(data)
    email=Booking.find(data[0].to_i).cost_sheet.lead.email
    @current_personnel = data[2]
    mail.attachments['Agreement.pdf']={mime_type: 'application/pdf', content: data[1] }
    mail :from => @current_personnel.email, :to => email, :bcc => @current_personnel.email, :subject => "Agreement"
end

def demand_notice(data)
    ledger_entry_header_id = data[1]
    @ledger_entry_header = LedgerEntryHeader.find(ledger_entry_header_id.to_i)
    personnel = data[2]
    mail.attachments['demand_notice.pdf']={mime_type: 'application/pdf', content: data[0] }
    mail :from => personnel.email, :to => 'dipakpramanik@thejaingroup.com, ayush@thejaingroup.com', :subject => "Demand Notice" 
end

def time_based_demand(data)
    @all_flats = data
    @flats=[]
    @all_flats.each do |flat_data|
        booking = Booking.find(flat_data[0].to_i)
        flat=Flat.find(booking.cost_sheet.flat_id)
        milestone = Milestone.find(flat_data[1].to_i)
        ledger_entry_items = LedgerEntryItem.includes(:ledger_entry_header).where(:ledger_entry_headers => {booking_id: booking.id})
        if ledger_entry_items ==[]
        else
            previous_ledger_entry_item = ledger_entry_items.sort_by{|x| x.created_at}.last
            time_based_milestone = TimeBasedMilestone.where('previous_payment_milestone_id = ? OR subsequent_payment_milestone_id = ?', milestone.payment_milestone_id, milestone.payment_milestone_id)[0]
            due_date = previous_ledger_entry_item.ledger_entry_header.date+time_based_milestone.days_after.days
            delay = (((Time.now-due_date)/24.hours).to_i)
            @flats+=[[flat, milestone.payment_milestone.description, due_date, delay, booking.cost_sheet.milestone_amount(milestone.id)]]
        end
    end
    mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com', :subject => 'Time based Demand Generation Alert'
end

def outstanding_interest_reminder(data)
    @flat = data[0]
    @outstanding = data[1]
    @accrued_interest = data[2]

    if @flat.lead.email == nil || @flat.lead.email == ''
    else
        mail :from => "rupsa@thejaingroup.com", :to => @flat.lead.email, :bcc => 'rupsa@thejaingroup.com, suvrajyoti@thejaingroup.com' ,:subject => 'Outstanding and Delay Charges Reminder' 
    end
end

    def deleted_leads_report(data)
        @all_deleted_leads = data[0]
        @personnel = data[1]

        mail :from => 'notifications@trackenquiry.com', :to => "ayush@thejaingroup.com, dipakpramanik@thejaingroup.com", :subject => 'Deleted Leads Report'
    end

    def extra_lead_details(data)
        @extra_leads = data
        mail :from => 'notifications@trackenquiry.com', :to => "ayush@thejaingroup.com", :subject => 'Extra Leads' 
    end

    def send_credit_note(data)
        credit_note_id = data[0]
        credit_note = CreditNoteEntry.find(credit_note_id.to_i)
        @lead = Lead.find(credit_note.booking.cost_sheet.lead_id)
        @flat = Flat.find(credit_note.booking.cost_sheet.flat_id)
        mail.attachments['credit_note.pdf']={mime_type: 'application/pdf', content: data[1] }
        if @lead.email==nil
        else
            mail :from => 'samanta@thejaingroup.com', :to => @lead.email, :cc => 'pallabita@thejaingroup.com, dipakpramanik@thejaingroup.com', :subject => "Credit Note"
        end    
    end

    def costing_report_import_errors(data)
        @errors = data[0]
        @missed_adds = data[1]
        mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com', :subject => 'facebook import error report'
    end

    def lead_transferring(data)
        @transferred_lead_count = data[0]
        @project = BusinessUnit.find(data[1].to_i) 
        @executive = Personnel.find(data[2].to_i)
        if @project.name == "Dream One" || @project.name == "Dream Palazzo" || @project.name == "Dream Residency Manor" || @project.name == "Dream Exotica"
            mail :from => 'notifications@trackenquiry.com', :to => 'nakhyastra@thejaingroup.com, dipakpramanik@thejaingroup.com', :bcc => 'anjali@thejaingroup.com', :subject => 'Lead Rescheduled'
        elsif @project.name == "Dream Eco City"
            mail :from => 'notifications@trackenquiry.com', :to => 'chanchal@thejaingroup.com, dipakpramanik@thejaingroup.com', :subject => 'Lead Rescheduled'
        elsif @project.name == "Dream One Hotel Apartment"
            mail :from => 'notifications@trackenquiry.com', :to => 'rahulsingh@thejaingroup.com, dipakpramanik@thejaingroup.com', :subject => 'Lead Rescheduled'
        end
    end
	
    def project_wise_data(data)
        @all_leads = data
        p @all_leads
        p "=========================================="
    end

    def other_enquiry(data)
        @all_params = data
        mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com', :subject => 'jaingroup website form data'
    end

    def weekly_tat_report(data)
        @bu_wise_fresh_leads = data[0]
        @bu_wise_total_mins = data[1]
        @total_delay = 0.0
        @bu_wise_total_mins.each do |key, value|
            value.each do |subkey, subvalue|
                @total_delay += subvalue.to_f
            end
        end
        mail :from => 'notifications@trackenquiry.com', :to => 'chanchal@thejaingroup.com, nakhyastra@thejaingroup.com', :cc => 'rishi@thejaingroup.com, jaingroupcaller8@thejaingroup.com, jaingroupcaller9@thejaingroup.com, jaingroupcaller7@thejaingroup.com, jaingroupcaller6@thejaingroup.com, jaingroupcaller1@thejaingroup.com, jaingroupcaller5@thejaingroup.com, jaingroupcaller3@thejaingroup.com, dipakpramanik@thejaingroup.com, ayush@thejaingroup.com', :subject => 'Weekly Turn Around Time Report' 
        # mail :to => 'dipakpramanik@thejaingroup.com', :subject => 'Weekly Turn Around Time Report'
    end

    def customer_outstanding_mail(data)
        @project_wise_outstandings = data[0]
        mail :from => 'notifications@trackenquiry.com', :to => 'dipakpramanik@thejaingroup.com, customercare1@thejaingroup.com, customercare2@thejaingroup.com, customercare3@thejaingroup.com', :subject => "outstanding data"
    end

    # varsha, sarnali, jenifer, sudipta, megha,
    # last 3 month  checking 
end