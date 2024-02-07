class DemandController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:dwc_parallel_outstanding_feed, :dwc_parallel_collection_feed, :parallel_outstanding_feed, :parallel_collection_feed]

def oriental
render :layout => false 
end

def e_signature
end

def booking_confirmation_form
@unconfirmed_cost_sheets=CostSheet.includes(:bookings, :lead => [:business_unit]).where(not_finalized: nil, confirmed: nil, :bookings => {cost_sheet_id: nil}, :business_units =>{organisation_id: current_personnel.organisation_id})	
# populate all unconfirmed cost sheets which have been booked by pre sales
# provide button to confirm booking
end

def confirm_booking_submit
	if params[:booking_confirmed]=='Booking Confirmed'
	  	redirect_to controller: 'demand', action: 'confirm_booking', params: request.request_parameters 
  elsif params[:booking_form]=='Booking Form'
      redirect_to controller: 'demand', action: 'booking_form', params: request.request_parameters
	elsif params[:booking_confirmed]=='Useless'
	    redirect_to controller: 'demand', action: 'cost_sheet_useless_mark', params: request.request_parameters
	end
end

def booking_form
  @occupations=selections_with_other(Occupation, :description)
  @designations=selections_with_other(Designation, :description)
  @nationalities = selections_with_other(Nationality, :description)
  @companies = selections_with_other(Company, :name)
  @business_units = selections(BusinessUnit, :name)
  @blocks = selectoptions(Block, :name)
  cost_sheet_id = params[:cost_sheet_ids]
  @cost_sheet = CostSheet.find(cost_sheet_id[0].to_i)
  @source_categories=SourceCategory.leaves(current_personnel)
  @source_categories+=[[@cost_sheet.lead.source_category.heirarchy, @cost_sheet.lead.source_category_id]]   
  @source_pick=[@cost_sheet.lead.source_category.heirarchy, @cost_sheet.lead.source_category_id]
  @bank_names=['HSBC','HDFC','Bandhan Bank','ICICI', 'Federal', 'YES', 'SBI','AXIS','BOI','Indian Bank','BOB','Canara Bank','PNB','Union Bank','ALLAHABAD BANK','Other']
  @payment_modes=['NEFT', 'RTGS', 'CHEQUE', 'CASH', 'ONLINE TRANSFER']
  position_1 = @cost_sheet.lead.name[0..5].index(" ")
  if position_1 == nil
    @actual_name_1 = @cost_sheet.lead.name
  else
    @title_1 = @cost_sheet.lead.name[0..position_1-1]
    @actual_name_1 = @cost_sheet.lead.name[position_1+1..@cost_sheet.lead.name.length]
  end
  if @cost_sheet.lead.second_applicant == nil || @cost_sheet.lead.second_applicant == ''
  else
    position_2 = @cost_sheet.lead.second_applicant[0..5].index(" ")
    if position_2 == nil
      @actual_name_2 = @cost_sheet.lead.second_applicant
    else
      @title_2 = @cost_sheet.lead.second_applicant[0..position_2-1]
      @actual_name_2 = @cost_sheet.lead.second_applicant[position_2+1..@cost_sheet.lead.second_applicant.length]
    end
  end
  if @cost_sheet.lead.first_applicant_father == nil || @cost_sheet.lead.first_applicant_father == ''
  else
    position_3 = @cost_sheet.lead.first_applicant_father[0..5].index(" ")
    if position_3 == nil
      @actual_name_3 = @cost_sheet.lead.first_applicant_father
    else
      @title_3 = @cost_sheet.lead.first_applicant_father[0..position_3-1]
      @actual_name_3 = @cost_sheet.lead.first_applicant_father[position_3+1..@cost_sheet.lead.first_applicant_father.length]
    end
  end
  if @cost_sheet.lead.first_applicant_mother == nil || @cost_sheet.lead.first_applicant_mother == ''
  else
    position_4 = @cost_sheet.lead.first_applicant_mother[0..5].index(" ")
    if position_4 == nil
      @actual_name_4 = @cost_sheet.lead.first_applicant_mother
    else
      @title_4 = @cost_sheet.lead.first_applicant_mother[0..position_4-1]
      @actual_name_4 = @cost_sheet.lead.first_applicant_mother[position_4+1..@cost_sheet.lead.first_applicant_mother.length]
    end
  end
  if @cost_sheet.lead.Second_applicant_father == nil || @cost_sheet.lead.Second_applicant_father == ''
  else
    position_5 = @cost_sheet.lead.Second_applicant_father[0..5].index(" ")
    if position_5 == nil
      @actual_name_5 = @cost_sheet.lead.Second_applicant_father
    else
      @title_5 = @cost_sheet.lead.Second_applicant_father[0..position_5-1]
      @actual_name_5 = @cost_sheet.lead.Second_applicant_father[position_5+1..@cost_sheet.lead.Second_applicant_father.length]
    end
  end
  if @cost_sheet.lead.Second_applicant_mother == nil || @cost_sheet.lead.Second_applicant_mother == ''
  else
    position_6 = @cost_sheet.lead.Second_applicant_mother[0..5].index(" ")
    if position_6 == nil
      @actual_name_6 = @cost_sheet.lead.Second_applicant_mother
    else
      @title_6 = @cost_sheet.lead.Second_applicant_mother[0..position_6-1]
      @actual_name_6 = @cost_sheet.lead.Second_applicant_mother[position_6+1..@cost_sheet.lead.Second_applicant_mother.length]
    end
  end
  if @cost_sheet.lead.spouse_name == nil || @cost_sheet.lead.spouse_name == ''
  else
    position_7 = @cost_sheet.lead.spouse_name[0..5].index(" ")
    if position_7 == nil
      @actual_name_7 = @cost_sheet.lead.spouse_name
    else
      @title_7 = @cost_sheet.lead.spouse_name[0..position_7-1]
      @actual_name_7 = @cost_sheet.lead.spouse_name[position_7+1..@cost_sheet.lead.spouse_name.length]
    end
  end
  if @cost_sheet.lead.second_applicant_spouse_name == nil || @cost_sheet.lead.second_applicant_spouse_name == ''
  else
    position_8 = @cost_sheet.lead.second_applicant_spouse_name[0..5].index(" ")
    if position_8 == nil
      @actual_name_8 = @cost_sheet.lead.second_applicant_spouse_name
    else
      @title_8 = @cost_sheet.lead.second_applicant_spouse_name[0..position_8-1]
      @actual_name_8 = @cost_sheet.lead.second_applicant_spouse_name[position_8+1..@cost_sheet.lead.second_applicant_spouse_name.length]
    end
  end
end

  def populate_occupation_other
    @occupation_type=params[:type]
    if @occupation_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_occupation_other"}
      end
    end
  end

  def populate_designation_other
    @designation_type=params[:type]
    if @designation_type == " Others"
      respond_to do |format|
          format.js { render :action => "populate_designation_other"}
      end
    end
  end

  def populate_second_applicant_form
    @form_value=params[:form_value]
    @occupations = selections_with_other(Occupation, :description)
    @designations = selections_with_other(Designation, :description)
    if @form_value == true || @form_value == "true"
      respond_to do |format|
          format.js { render :action => "populate_second_applicant_form"}
      end
    end
  end

  def populate_second_applicant_signature
    @form_value=params[:form_value]
    if @form_value == true || @form_value == "true"
      respond_to do |format|
          format.js { render :action => "populate_second_applicant_signature"}
      end
    end
  end

  def booking_form_submit
    cost_sheet_id = params[:cost_sheet_id]
    cost_sheet = CostSheet.find(cost_sheet_id.to_i)
    cost_sheet.lead.update(name: params[:lead_title]+' '+params[:lead][:name], first_applicant_father: params[:lead][:father_title]+' '+params[:lead][:father_of_first_applicant], first_applicant_mother: params[:lead][:mother_title]+' '+params[:lead][:mother_of_first_applicant], spouse_name: params[:lead][:spouse_title]+' '+params[:lead][:spouse_name], dob: params[:lead][:dob].to_datetime, pan: params[:lead][:pan], company: params[:lead][:company], mobile: params[:lead][:mobile], email: params[:lead][:email], doa: params[:lead][:doa].to_datetime, nationality_id: params[:lead][:nationality_id], first_applicant_aadhar: params[:lead][:first_applicant_aadhar], qualification_of_first_applicant: params[:lead][:qualification_of_first_applicant], address: params[:lead][:address], second_applicant: params[:lead][:second_applicant_title]+' '+params[:lead][:second_applicant], Second_applicant_father: params[:lead][:second_applicant_father_title]+' '+params[:lead][:father_of_second_applicant], Second_applicant_mother: params[:lead][:second_applicant_mother_title]+' '+params[:lead][:mother_of_second_applicant], second_applicant_spouse_name: params[:lead][:second_applicant_spouse_title]+' '+params[:lead][:second_applicant_spouse_name], second_applicant_DOB: params[:lead][:second_applicant_DOB], second_applicant_pan: params[:lead][:second_applicant_pan], second_applicant_company: params[:lead][:second_applicant_company], second_applicant_mobile: params[:lead][:second_applicant_mobile], second_applicant_email: params[:lead][:second_applicant_email], second_applicant_aadhar: params[:lead][:second_applicant_aadhar], qualification_of_second_applicant: params[:lead][:qualification_of_second_applicant], source_category_id: params[:lead][:source_category_id], pincode: params[:lead][:pincode])
    if params[:lead][:occupation_id] == "-1" || params[:lead][:occupation_id] == -1
      occupation = Occupation.new
      occupation.description = params[:occupation][:other]
      occupation.organisation_id = current_personnel.organisation_id
      occupation.save

      cost_sheet.lead.update(occupation_id: occupation.id)
    else
      cost_sheet.lead.update(occupation_id: params[:lead][:occupation_id].to_i)
    end
    
    if params[:lead][:designation_id] == "-1" || params[:lead][:designation_id] == -1
      designation = Designation.new
      designation.description = params[:designation][:other]
      designation.organisation_id = current_personnel.organisation_id
      designation.save

      cost_sheet.lead.update(designation_id: designation.id)
    else
      cost_sheet.lead.update(designation_id: params[:lead][:designation_id].to_i)
    end

    if params[:lead][:nationality_id] == "-1"
      nationality = Nationality.new
      nationality.description = params[:nationality][:other]
      nationality.organisation_id = current_personnel.organisation_id
      nationality.save
      cost_sheet.lead.update(nationality_id: nationality.id)
    else
      cost_sheet.lead.update(nationality_id: params[:lead][:nationality_id].to_i)
    end

    if params[:lead][:second_applicant_occupation_id] == "-1" || params[:lead][:second_applicant_occupation_id] == -1
      occupation = Occupation.new
      occupation.description = params[:second_occupation][:other]
      occupation.organisation_id = current_personnel.organisation_id
      occupation.save

      cost_sheet.lead.update(second_applicant_occupation_id: occupation.id)
    else
      cost_sheet.lead.update(second_applicant_occupation_id: params[:lead][:second_applicant_occupation_id].to_i)
    end

    if params[:lead][:second_applicant_designation_id] == "-1"
      designation = Designation.new
      designation.description = params[:second_designation][:other]
      designation.organisation_id = current_personnel.organisation_id
      designation.save
      cost_sheet.lead.update(second_applicant_designation_id: designation.id)
    else
      cost_sheet.lead.update(second_applicant_designation_id: params[:lead][:second_applicant_designation_id].to_i)
    end

    if params[:same_address] == "true"
      cost_sheet.lead.update(current_address: params[:lead][:address])
    else
      cost_sheet.lead.update(current_address: params[:lead][:current_address])
    end

    if params[:referred_lead] == nil
    else
      params[:referred_lead][:name].each_with_index do |referred_lead, index|
        wish_to_customer = WishToCustomer.new
        wish_to_customer.name = params[:referred_lead][:name]
        wish_to_customer.email = params[:referred_lead][:email]
        wish_to_customer.mobile = params[:referred_lead][:mobile]
        wish_to_customer.save

        referred_lead = ReferredLead.new
        referred_lead.wish_to_customer_id = wish_to_customer.id
        referred_lead.lead_id = cost_sheet.lead_id
      end
    end

    if params[:children_name] == []
    else
      multiple_children = MultipleChild.where(lead_id: cost_sheet.lead_id)
      if multiple_children == []
        params[:children_name].each_with_index do |children_name, index|
          multiple_child = MultipleChild.new
          multiple_child.name = children_name
          multiple_child.dob = params[:children_dob][index]
          multiple_child.lead_id = cost_sheet.lead_id
          multiple_child.save
        end
      else
        multiple_children.destroy_all
        params[:children_name].each_with_index do |children_name, index|
          multiple_child = MultipleChild.new
          multiple_child.name = children_name
          multiple_child.dob = params[:children_dob][index]
          multiple_child.lead_id = cost_sheet.lead_id
          multiple_child.save
        end
      end
    end
    if params[:lead][:loan_under_PMAY]==nil
      cost_sheet.lead.update(loan_under_PMAY: nil)
    else
      cost_sheet.lead.update(loan_under_PMAY: true)
    end

    if params[:booking][:date] == nil || params[:booking][:date] == ""
    else
      all_bookings=Booking.includes(:cost_sheet => [:flat => [:block ]]).where(:blocks => {business_unit_id: CostSheet.find(cost_sheet_id).flat.block.business_unit_id}).count
      booking=Booking.new
      booking.cost_sheet_id = cost_sheet.id
      booking.date = params[:booking][:date]
      booking.serial = all_bookings+1
      booking.save

      @cost_sheet_pdf=render_to_string(:partial => "welcome_letter_send", :layout => false, :locals => { :cost_sheet_id => cost_sheet_id.to_i})
      @cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
      @pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
    
      data=[cost_sheet_id, current_personnel, @pdf]
      UserMailer.welcome_letter(data).deliver
      if current_personnel.organisation_id == 6
        if booking.cost_sheet.lead.business_unit.organisation.whatsapp_instance == nil
        else
          whatsapp_pdf=Base64.encode64(@pdf) 
          whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
            
          # welcome_message = 'Dear '+booking.cost_sheet.lead.name+','+"\n"+"\n"+'*Greeting from The JSB Infrastructures*'+"\n"+"\n"+'Whilst expressing our deep appreciation towards your investment in '+'*'+booking.cost_sheet.flat.block.business_unit.name+'*'+ ' - Assam’s most technologically advanced home , we further feel privileged for having placed your trust on us in selecting your Dream Home.'+"\n"+'By way of this message, please be intimated that we have received the application for '+'*Flat No.'+booking.cost_sheet.flat.full_name+', '+booking.cost_sheet.flat.floor.to_s+' Floor, '+booking.cost_sheet.flat.block.name+' of '+booking.cost_sheet.flat.block.business_unit.name+'*'+"\n"+"\n"+'Please feel free to get in touch with the undersigned with any queries/ feedback or for assistance. It is always our pleasure to be of service to you today and in the future.'+"\n"+"\n"+'Once again we warmly welcome you to the growing '+booking.cost_sheet.flat.block.business_unit.name+' family.'+"\n"+"\n"+'--'+"\n"+'Warm Regards,'+"\n"+"\n"+current_personnel.name+"\n"+'Manager- Post Sales'+"\n"+booking.cost_sheet.flat.block.business_unit.name+"\n"+current_personnel.mobile.to_s
          urlstring =  "https://eu71.chat-api.com/instance"+(booking.cost_sheet.lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(booking.cost_sheet.lead.personnel.organisation.whatsapp_key)
          result = HTTParty.get(urlstring,
           :body => { :phone => "91"+(booking.cost_sheet.lead.mobile),
                      :body => whatsapp_pdf,
                      :filename => 'Welcome Letter.pdf' 
                      }.to_json,
           :headers => { 'Content-Type' => 'application/json' } )

          urlstring =  "https://eu71.chat-api.com/instance"+(booking.cost_sheet.lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(booking.cost_sheet.lead.personnel.organisation.whatsapp_key)
          result = HTTParty.get(urlstring,
           :body => { :phone => current_personnel.mobile,
                      :body => whatsapp_pdf,
                      :filename => 'Welcome Letter.pdf' 
                      }.to_json,
           :headers => { 'Content-Type' => 'application/json' } )
        end
      end

      ledger_entry_header=LedgerEntryHeader.new
      ledger_entry_header.booking_id = booking.id
      ledger_entry_header.date = DateTime.now
      ledger_entry_header.save

      ledger_entry_item=LedgerEntryItem.new
      ledger_entry_item.milestone_id = Milestone.where(payment_plan_id: cost_sheet.payment_plan_id).sort_by{|x| x.order}.first.id
      ledger_entry_item.ledger_entry_header_id=ledger_entry_header.id
      ledger_entry_item.save

      @demand_pdf=render_to_string(:partial => "demand_preview_index", :layout => false, :locals => { :ledger_entry_header_id => ledger_entry_header.id})
      @demand_pdf='<html><body>'+@demand_pdf+'</body></html>'
      @pdf = WickedPdf.new.pdf_from_string(@demand_pdf)
      data=[ledger_entry_header.id,@pdf, current_personnel]
      UserMailer.send_demand(data).deliver
  
      whatsapp_pdf=Base64.encode64(@pdf) 
      whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
      lead = cost_sheet.lead
      urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.mobile))
      result = HTTParty.get(urlstring)
      if result.parsed_response['result'] != 'not exists'            
        urlstring =  "https://eu71.chat-api.com/instance"+(LedgerEntryHeader.find(ledger_entry_header.id.to_i).booking.cost_sheet.lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(LedgerEntryHeader.find(ledger_entry_header.id.to_i).booking.cost_sheet.lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(lead.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(current_personnel.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
      else 
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.other_number))
        result = HTTParty.get(urlstring)
        if result.parsed_response['result'] != 'not exists'
          urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
          result = HTTParty.get(urlstring,
           :body => { :phone => "91"+(lead.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
          urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
          result = HTTParty.get(urlstring,
           :body => { :phone => "91"+(current_personnel.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
        else
        end
      end
    end

    if params[:demand_money_receipt] == nil
    else
      demand_money_receipt=DemandMoneyReceipt.new
      money_receipt_serial=MoneyReceiptSerial.find_by(business_unit_id: booking.cost_sheet.flat.block.business_unit_id)
      if money_receipt_serial != nil
        demand_money_receipt.serial=money_receipt_serial.last+1
        money_receipt_serial.update(last: money_receipt_serial.last+1)
      end
      demand_money_receipt.booking_id = booking.id
      demand_money_receipt.date = params[:demand_money_receipt][:date]
      demand_money_receipt.amount = params[:demand_money_receipt][:amount]
      demand_money_receipt.cheque_number = params[:demand_money_receipt][:cheque_number]
      if params[:other_bank_name] == nil 
       demand_money_receipt.bank_name = params[:demand_money_receipt][:bank_name]
      else
        demand_money_receipt.bank_name = params[:other_bank_name]
      end
      demand_money_receipt.instrument_date = params[:demand_money_receipt][:instrument_date]
      demand_money_receipt.payment_mode = params[:demand_money_receipt][:payment_mode]
      demand_money_receipt.save

      @demand_money_receipt_pdf=render_to_string(:partial => "demand_money_receipt_with_gst_preview_index", :layout => false, :locals => { :demand_money_receipt_id => demand_money_receipt.id})
      @demand_money_receipt_pdf='<html><body>'+@demand_money_receipt_pdf+'</body></html>'
      @pdf = WickedPdf.new.pdf_from_string(@demand_money_receipt_pdf)
      data=[demand_money_receipt.id,@pdf,current_personnel]
      UserMailer.send_demand_money_receipt(data).deliver
      
      lead = cost_sheet.lead
      urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.mobile))
      result = HTTParty.get(urlstring)
      whatsapp_pdf=Base64.encode64(@pdf) 
      whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
      if result.parsed_response['result'] != 'not exists'            
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(lead.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand Money Receipt.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(current_personnel.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand Money Receipt.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
      else 
        if lead.other_number == nil || lead.other_number == ''
        else
          urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.other_number))
          result = HTTParty.get(urlstring)
          if result.parsed_response['result'] != 'not exists'
            urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
            result = HTTParty.get(urlstring,
             :body => { :phone => "91"+(lead.other_number),
                        :body => whatsapp_pdf,
                        :filename => 'Demand Money Receipt.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )
            urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
            result = HTTParty.get(urlstring,
             :body => { :phone => "91"+(current_personnel.mobile),
                        :body => whatsapp_pdf,
                        :filename => 'Demand Money Receipt.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )
          else
          end
        end
      end
    end

    flash[:success]='Booking form submited successfully.'
    redirect_to demand_booking_confirmation_form_url
  end

  def booking_preview
    @booking = Booking.find(params[:format])
    @demand_money_receipt = DemandMoneyReceipt.where(booking_id: @booking.id).sort_by{|x| x.created_at}[0]
  end

  def booking_form_download_and_mail
    @booking_id = params[:booking_id]
    @booking = Booking.find(@booking_id.to_i)
    @booking_form_pdf=render_to_string(:partial => "booking_preview", :layout => false, :locals => { :booking_id => @booking_id})
    @booking_form_pdf='<html><body>'+@booking_form_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@booking_form_pdf)
    if params[:commit] == 'Download'
      send_data(@pdf, filename: 'booking_form.pdf', type: 'application/pdf')
    elsif params[:commit] == 'Email'
      data = [@booking_id, @pdf, current_personnel]
      UserMailer.send_booking_form(data).deliver
      
      flash[:success]='Email send successfully.'
      redirect_to demand_bookings_url
    elsif params[:commit] == 'Whatsapp'
      lead = @booking.cost_sheet.lead
      urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.mobile))
      result = HTTParty.get(urlstring)
      whatsapp_pdf=Base64.encode64(@pdf) 
      whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
      if result.parsed_response['result'] != 'not exists'            
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(lead.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Booking Form.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(current_personnel.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Booking Form.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )

        flash[:success]='Whatsapp send successfully.'
      else 
        if lead.other_number == nil || lead.other_number == ''
        else
          urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.other_number))
          result = HTTParty.get(urlstring)
          if result.parsed_response['result'] != 'not exists'
            urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
            result = HTTParty.get(urlstring,
             :body => { :phone => "91"+(lead.other_number),
                        :body => whatsapp_pdf,
                        :filename => 'Booking Form.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )
            urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
            result = HTTParty.get(urlstring,
             :body => { :phone => "91"+(current_personnel.mobile),
                        :body => whatsapp_pdf,
                        :filename => 'Booking Form.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )
            flash[:success]='Whatsapp send successfully.'
          else
            flash[:danger]='Number not active on Whatsapp'  
          end
        end
      end

      redirect_to demand_bookings_url
    end  
  end

def booking_submit_for_action 
	if params[:commit]=='Raise Demand'
	  	redirect_to controller: 'demand', action: 'adhoc_demand_form', params: request.request_parameters 
  elsif params[:commit]=='Send Welcome Letter'
	    redirect_to controller: 'demand', action: 'send_welcome_letter', params: request.request_parameters
  elsif params[:commit]=='Agreement'
    redirect_to controller: 'demand', action: 'aggrement_preview', params: request.request_parameters
  elsif params[:commit]=='Mortgage NOC'
    redirect_to controller: 'demand', action: 'mortgage_noc_preview', params: request.request_parameters
  elsif params[:commit]=='Builder NOC'
    redirect_to controller: 'demand', action: 'builder_noc_preview', params: request.request_parameters
  elsif params[:commit]=='Allotment Letter'
    redirect_to controller: 'demand', action: 'Allotment_letter_preview', params: request.request_parameters
	end
end

def Allotment_letter_preview
  @booking = Booking.find(params[:booking_id])
end

def allotment_letter_download_mail
  @booking_id=params[:booking_id]
  @allotment_pdf=render_to_string(:partial => "allotment_letter_preview", :layout => false, :locals => { :booking_id => @booking_id})
  @allotment_pdf='<html><body>'+@allotment_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@allotment_pdf)
  if params[:commit] == 'Download'
    send_data(@pdf, filename: 'Allotment.pdf', type: 'application/pdf')
  elsif params[:commit] == 'Email'
    data = [@booking_id, @pdf, current_personnel]
    UserMailer.send_allotment_letter(data).deliver
    
    flash[:success]='Email send successfully.'
    redirect_to demand_bookings_url
  end
end

def unconfirmed_booking
  booking=Booking.find(params[:format])
  booking.destroy

  redirect_to demand_bookings_url
end

def aggrement_preview
  @booking=Booking.find(params[:booking_id])
end

def aggrement_download_mail
  @booking_id=params[:booking_id]
  @booking_pdf=render_to_string(:partial => "aggrement_preview", :layout => false, :locals => { :booking_id => @booking_id})
  @booking_pdf='<html><body>'+@booking_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@booking_pdf)
  if params[:download]=='Download'
      send_data(@pdf, filename: 'Agreement.pdf', type: 'application/pdf')
  elsif params[:email]=='Email'
      data=[@booking_id, @pdf, current_personnel]
      UserMailer.send_agreement(data).deliver
      flash[:success]='Email send successfully.'
      redirect_to demand_bookings_url
  end
end

def aggrement_send

end

def mortgage_noc_preview
  if current_personnel.organisation_id == 6
    @bank_name = params[:bank_name]
  end
  @booking=Booking.find(params[:booking_id])
end

def mortgage_noc_send
  @booking_id=params[:booking_id]
  @bank_name = params[:bank_name]
  @mortgage_pdf=render_to_string(:partial => "mortgage_noc_preview", :layout => false, :locals => { :booking_id => @booking_id, :bank_name => @bank_name})
  @mortgage_pdf='<html><body>'+@mortgage_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@mortgage_pdf)
  if params[:commit] == 'Download'
    send_data(@pdf, filename: 'Mortgage-NOC.pdf', type: 'application/pdf')
  elsif params[:commit] == 'Email'
    data = [@booking_id, @pdf, current_personnel]
    UserMailer.send_mortgage_noc(data).deliver
    
    flash[:success]='Email send successfully.'
    redirect_to demand_bookings_url
  end
end

def builder_noc_preview
  @booking=Booking.find(params[:booking_id])
end

def builder_noc_send

end

def second_welcome_letter_send
	@booking=Booking.find(params[:booking_id])
	@milestones=Milestone.where(payment_plan_id: @booking.cost_sheet.payment_plan_id).sort_by{|x| x.order}
	booking_milestone=@milestones.first
    aggrement_milestone=@milestones.second
    @tax=Tax.where(business_unit: @booking.cost_sheet.lead.business_unit_id)[0]
    @servant_quarters=ServantQuarter.where(business_unit_id: @booking.cost_sheet.lead.business_unit_id)
    @servant_quarter_quantity=@booking.cost_sheet.servant_quarters
    @extra_development_charges=ExtraDevelopmentCharge.where(business_unit_id: @booking.cost_sheet.lead.business_unit_id)
    total_flat_amount=0.0
    total_parking_gross=0.0
    deduction=0.0
    total_extra_development_charges_gross=0.0
    servant_quarter_amnt=0.0
    gstamt_charges=0.0
    total_ota = 0.0
    gstamt_ota = 0.0
    gross_ota = 0.0
    charges = 0.0
    total_parking=0.0
    servant_quarter_amnt_gross=0.0
    total_unit=(@booking.cost_sheet.flat.rate*@booking.cost_sheet.flat.SBA).round
    gstamt_unit=((total_unit*@tax.basic)/100).round
    gross_unit=(total_unit+gstamt_unit).round
    total_escalation=((@booking.cost_sheet.flat.SBA)*@booking.cost_sheet.flat.flc_charge_rate).round
    gstamt_escalation=((total_escalation*@tax.plc)/100).round
    gross_escalation=(total_escalation+gstamt_escalation).round
    total_plc=(@booking.cost_sheet.flat.SBA*@booking.cost_sheet.flat.plc_charge_rate[1]).round
    gst_plc_amnt=((total_plc*@tax.plc)/100).round
    gross_plc=(total_plc+gst_plc_amnt).round
    @servant_quarters.each do |servant_quarter| 
        charges=(@servant_quarter_quantity*servant_quarter.rate).round
        servant_quarter_amnt+=charges
        gstamt_charges=((charges*@tax.servant_quarter)/100).round
        gross=(charges+gstamt_charges).round
        servant_quarter_amnt_gross+=gross
    end
    if @booking.cost_sheet.flat.OTA == nil || @booking.cost_sheet.flat.OTA == ''
    else
        total_ota=(@booking.cost_sheet.flat.rate*chargeable_ota).round
        gstamt_ota=((total_ota*@tax.basic)/100).round
        gross_ota=(total_ota+gstamt_ota).round
    end
    @car_parks=[]
    CostSheetCarParking.where(cost_sheet_id: @booking.cost_sheet.id).each do|cost_sheet_car_park_nature|
        car_park=CarPark.find_by_car_park_nature_id(cost_sheet_car_park_nature.car_parking_nature_id)
        @car_parks+=[[car_park,cost_sheet_car_park_nature.quantity]]
    end
    @car_parks.each do |car_park| 
    	quantity=car_park[1]
        parking=(quantity*car_park[0].rate).round
        total_parking+=parking
        gstamt_parking=((parking*@tax.car_park)/100).round
        gross=(parking+gstamt_parking).round
        total_parking_gross+=gross
    end
    total_flat_amount=(gross_unit+gross_escalation+gross_plc+servant_quarter_amnt_gross+total_parking_gross+gross_ota).round
    flat_value_with_out_gst=total_unit+total_escalation+total_plc+charges+total_parking+total_ota
    @extra_development_charges.each do |extra_development_charge| 
        if extra_development_charge.amount !=nil
            extra_development_charges= extra_development_charge.amount
        elsif extra_development_charge.rate !=nil 
            extra_development_charges=((@booking.cost_sheet.flat.SBA)*extra_development_charge.rate).round
        elsif extra_development_charge.percentage != nil
            extra_development_charges=((flat_value_with_out_gst*extra_development_charge.percentage)/100).round
        end
        gst_extra_development_charges=((extra_development_charges*@tax.edc)/100).round
        extra_development_charges_gross=extra_development_charges+gst_extra_development_charges
        total_extra_development_charges_gross+=extra_development_charges_gross
    end

    unit=0
    parking=0
    extra=0

    if aggrement_milestone.flat_value_percentage==nil 
        unit=aggrement_milestone.amount.to_i 
        deduction=unit 
    else 
        unit=((((total_flat_amount-total_parking_gross)*aggrement_milestone.flat_value_percentage)/100)-deduction).round 
        deduction=0 
    end   

    if aggrement_milestone.flat_value_percentage==nil 
        parking=0 
    else 
        parking=((total_parking_gross*aggrement_milestone.flat_value_percentage)/100).round 
    end   

    if aggrement_milestone.extra_development_charge_percentage==nil 
        extra=0 
    else 
        extra=((total_extra_development_charges_gross*aggrement_milestone.extra_development_charge_percentage)/100).round 
    end 
    
	@demand_money_receipts=DemandMoneyReceipt.where(booking_id: @booking.id).sort_by{|x| x.created_at}
	@demand_money_receipt_id=@demand_money_receipts.first.id
	@demand_money_receipt_pdf=render_to_string(:partial => "demand_money_receipt_preview_index", :layout => false, :locals => { :demand_money_receipt_id => @demand_money_receipt_id})
	@demand_money_receipt_pdf='<html><body>'+@demand_money_receipt_pdf+'</body></html>'
	# @money_receipt_pdf = WickedPdf.new.pdf_from_string(@demand_money_receipt_pdf)
	total_money_receipt_amount=0
	
	@demand_money_receipts.each do |demand_money_receipt|
		total_money_receipt_amount+=demand_money_receipt.amount
	end

	gross=(unit+parking+extra).round 
    @milestone_amount=gross-total_money_receipt_amount

	lead_id = @booking.cost_sheet.lead_id
	business_unit_id = @booking.cost_sheet.flat.block.business_unit_id
	flat_id = @booking.cost_sheet.flat_id
	payment_plan_id = @booking.cost_sheet.payment_plan_id
	servant_quarter_quantity = @booking.cost_sheet.servant_quarters
	discount = @booking.cost_sheet.discount_amount
	car_parks_quantity=[]
	car_park_quantity={}
	CostSheetCarParking.where(cost_sheet_id: @booking.cost_sheet_id).each do |cost_sheet_car_parking|
		car_park_quantity[cost_sheet_car_parking.car_parking_nature_id]=cost_sheet_car_parking.quantity
	end
	car_parks_quantity=car_park_quantity
  	@cost_sheet_pdf=render_to_string(:partial => "windows/cost_sheet_review", :layout => false, :locals => { :lead_id => lead_id, :business_unit_id => business_unit_id,:flat_id => flat_id, :payment_plan_id => payment_plan_id, :servant_quarter_quantity => servant_quarter_quantity, :car_parks_quantity => car_parks_quantity, :discount => discount})
	@cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
	@cost_sheet_pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
	
	data=[@booking, @money_receipt_pdf, @cost_sheet_pdf, @milestone_amount]
	UserMailer.second_welcome_letter(data).deliver

	flash[:success]='Welcome Letter Send successfully.'
	redirect_to demand_bookings_url
end

def cost_sheet_useless_mark
	params[:cost_sheet_ids].each do |cost_sheet_id|	
		cost_sheet=CostSheet.find_by_id(cost_sheet_id.to_i)
		cost_sheet.update(not_finalized: true)
	end

	flash[:success]='Useless Marking of Cost Sheets Done successfully.'
	redirect_to demand_booking_confirmation_form_url
end

def confirm_booking
  params[:cost_sheet_ids].each do |cost_sheet_id|
  	all_bookings=Booking.includes(:cost_sheet => [:flat => [:block ]]).where(:blocks => {business_unit_id: CostSheet.find(cost_sheet_id).flat.block.business_unit_id}).count
  	booking=Booking.new
  	booking.cost_sheet_id=cost_sheet_id
  	booking.date=params[:booking][:date]
  	booking.serial=all_bookings+1
  	booking.save

    

    # @cost_sheet_pdf=render_to_string(:partial => "welcome_letter_send", :layout => false, :locals => { :cost_sheet_id => cost_sheet_id.to_i})
    # @cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
    # @pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
  
    # data=[cost_sheet_id, current_personnel, @pdf]
    # UserMailer.welcome_letter(data).deliver
    # if current_personnel.organisation_id == 6
    #   if booking.cost_sheet.lead.business_unit.organisation.whatsapp_instance == nil
    #   else
    #     whatsapp_pdf=Base64.encode64(@pdf) 
    #     whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
          
    #     # welcome_message = 'Dear '+booking.cost_sheet.lead.name+','+"\n"+"\n"+'*Greeting from The JSB Infrastructures*'+"\n"+"\n"+'Whilst expressing our deep appreciation towards your investment in '+'*'+booking.cost_sheet.flat.block.business_unit.name+'*'+ ' - Assam’s most technologically advanced home , we further feel privileged for having placed your trust on us in selecting your Dream Home.'+"\n"+'By way of this message, please be intimated that we have received the application for '+'*Flat No.'+booking.cost_sheet.flat.full_name+', '+booking.cost_sheet.flat.floor.to_s+' Floor, '+booking.cost_sheet.flat.block.name+' of '+booking.cost_sheet.flat.block.business_unit.name+'*'+"\n"+"\n"+'Please feel free to get in touch with the undersigned with any queries/ feedback or for assistance. It is always our pleasure to be of service to you today and in the future.'+"\n"+"\n"+'Once again we warmly welcome you to the growing '+booking.cost_sheet.flat.block.business_unit.name+' family.'+"\n"+"\n"+'--'+"\n"+'Warm Regards,'+"\n"+"\n"+current_personnel.name+"\n"+'Manager- Post Sales'+"\n"+booking.cost_sheet.flat.block.business_unit.name+"\n"+current_personnel.mobile.to_s
    #     urlstring =  "https://eu71.chat-api.com/instance"+(booking.cost_sheet.lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(booking.cost_sheet.lead.personnel.organisation.whatsapp_key)
    #     result = HTTParty.get(urlstring,
    #      :body => { :phone => "91"+(booking.cost_sheet.lead.mobile),
    #                 :body => whatsapp_pdf,
    #                 :filename => 'Welcome Letter.pdf' 
    #                 }.to_json,
    #      :headers => { 'Content-Type' => 'application/json' } )

    #     urlstring =  "https://eu71.chat-api.com/instance"+(booking.cost_sheet.lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(booking.cost_sheet.lead.personnel.organisation.whatsapp_key)
    #     result = HTTParty.get(urlstring,
    #      :body => { :phone => current_personnel.mobile,
    #                 :body => whatsapp_pdf,
    #                 :filename => 'Welcome Letter.pdf' 
    #                 }.to_json,
    #      :headers => { 'Content-Type' => 'application/json' } )
    #   end
    # end
  end
  redirect_to :back
end

def send_welcome_letter
  booking_id = params[:booking_id]
  booking = Booking.find(booking_id.to_i)
  @cost_sheet_id = booking.cost_sheet_id
  @cost_sheet_pdf=render_to_string(:partial => "welcome_letter_send", :layout => false, :locals => { :cost_sheet_id => @cost_sheet_id})
  @cost_sheet_pdf='<html><body>'+@cost_sheet_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@cost_sheet_pdf)
  
  data = [booking.cost_sheet_id, current_personnel, @pdf]
  UserMailer.welcome_letter(data).deliver
  if current_personnel.organisation_id == 6
    if booking.cost_sheet.lead.business_unit.organisation.whatsapp_instance == nil
    else
      # welcome_message = 'Dear '+booking.cost_sheet.lead.name+','+"\n"+"\n"+'*Greeting from The JSB Infrastructures*'+"\n"+"\n"+'Whilst expressing our deep appreciation towards your investment in '+'*'+booking.cost_sheet.flat.block.business_unit.name+'*'+ ' - Assam’s most technologically advanced home , we further feel privileged for having placed your trust on us in selecting your Dream Home.'+"\n"+'By way of this message, please be intimated that we have received the application for '+'*Flat No.'+booking.cost_sheet.flat.full_name+', '+booking.cost_sheet.flat.floor.to_s+' Floor, '+booking.cost_sheet.flat.block.name+' of '+booking.cost_sheet.flat.block.business_unit.name+'*'+"\n"+"\n"+'Please feel free to get in touch with the undersigned with any queries/ feedback or for assistance. It is always our pleasure to be of service to you today and in the future.'+"\n"+"\n"+'Once again we warmly welcome you to the growing '+booking.cost_sheet.flat.block.business_unit.name+' family.'+"\n"+"\n"+'--'+"\n"+'Warm Regards,'+"\n"+"\n"+current_personnel.name+"\n"+'Manager- Post Sales'+"\n"+booking.cost_sheet.flat.block.business_unit.name+"\n"+current_personnel.mobile.to_s
      urlstring =  "https://eu71.chat-api.com/instance"+(booking.cost_sheet.lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(booking.cost_sheet.lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+'8389822643',
                    :body => @pdf,
                    :filename => 'Welcome Letter.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
    end
  end
  redirect_to demand_bookings_url
end

def dwc_parallel_outstanding_feed
total_outstanding=0
  Booking.includes(:cost_sheet => [:lead]).where(:bookings => {ignore: nil}, :leads => {business_unit_id: 3}).each do |booking|
  total_outstanding+=booking.demand_outstanding
  end
render text: total_outstanding.to_s 
end

def dwc_parallel_collection_feed
collection=[]
total=0
  7.times do |count|
  total=0  
  from=(Time.now-count.month).beginning_of_month
  to=(Time.now-count.month).end_of_month  
  money_receipts=DemandMoneyReceipt.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {id: 3}).where('demand_money_receipts.date >= ? and demand_money_receipts.date <= ? and (bookings.ignore is ? or bookings.ignore=?)', from, to, nil, false)       
    money_receipts.each do |money_receipt|
      total+=money_receipt.amount
    end
  collection+=[total.round]  
  end
render text: collection.to_s 
end

def parallel_outstanding_feed
total_outstanding=0
	Booking.includes(:cost_sheet => [:lead]).where(:bookings => {ignore: nil}, :leads => {business_unit_id: 2}).each do |booking|
	total_outstanding+=booking.demand_outstanding
	end
render text: total_outstanding.to_s	
end

def parallel_collection_feed
collection=[]
total=0
  7.times do |count|
  total=0  
  from=(Time.now-count.month).beginning_of_month
  to=(Time.now-count.month).end_of_month  
  money_receipts=DemandMoneyReceipt.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {id: 2}).where('demand_money_receipts.date >= ? and demand_money_receipts.date <= ? and (bookings.ignore is ? or bookings.ignore=?)', from, to, nil, false)       
    money_receipts.each do |money_receipt|
      total+=money_receipt.amount
    end
  collection+=[total.round]  
  end
render text: collection.to_s 
end

def demand_money_receipt_index
	@money_receipts=DemandMoneyReceipt.includes(:booking => [:cost_sheet => [:flat => [:block =>[:business_unit]]]]).where(:business_units => {organisation_id: current_personnel.organisation_id})
end

def money_receipt_entry_form
	@customer_with_flats=[]
	Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(cancelled: nil).each do |booking|
		@customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.id]]
	end
	@customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
	@bank_names=['HSBC','HDFC','Bandhan Bank','ICICI', 'Federal', 'YES', 'SBI','AXIS','BOI','Indian Bank','BOB','Canara Bank','PNB','Union Bank','ALLAHABAD BANK','Other']
	@payment_modes=['NEFT', 'RTGS', 'CHEQUE', 'CASH', 'ONLINE TRANSFER']
# customer dropdown to be fetched from bookings table, thru cost_sheet_id
end

def populate_bank_other
  @bank_name=params[:name]
  if @bank_name == "Other"
    respond_to do |format|
        format.js { render :action => "populate_bank_other"}
    end
  end
end

def money_receipt_entry
	duplicate_bill=false
  if params[:demand_money_receipt][:payment_mode] == 'CHEQUE'
    money_receipts = DemandMoneyReceipt.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(booking_id: params[:demand_money_receipt][:booking_id], payment_mode: 'CHEQUE')
    money_receipts.each do |money_receipt|
      if money_receipt.bank_name == params[:demand_money_receipt][:bank_name] && money_receipt.cheque_number == params[:demand_money_receipt][:cheque_number]
        duplicate_bill = true
        break
      elsif money_receipt.bank_name == params[:demand_money_receipt][:bank_name] && money_receipt.cheque_number != params[:demand_money_receipt][:cheque_number]
        duplicate_bill = false
      elsif money_receipt.bank_name != params[:demand_money_receipt][:bank_name] && money_receipt.cheque_number == params[:demand_money_receipt][:cheque_number]
        duplicate_bill = false
      elsif money_receipt.bank_name != params[:demand_money_receipt][:bank_name] && money_receipt.cheque_number != params[:demand_money_receipt][:cheque_number]
        duplicate_bill =false
      end
    end
    if duplicate_bill == false
      money_receipt=DemandMoneyReceipt.new
      booking=Booking.find(params[:demand_money_receipt][:booking_id].to_i)
      money_receipt_serial=MoneyReceiptSerial.find_by(business_unit_id: booking.cost_sheet.flat.block.business_unit_id)
      if money_receipt_serial != nil
        money_receipt.serial=money_receipt_serial.last+1
        money_receipt_serial.update(last: money_receipt_serial.last+1)
      end
      money_receipt.booking_id = params[:demand_money_receipt][:booking_id]
      money_receipt.date = params[:demand_money_receipt][:date]
      money_receipt.amount = params[:demand_money_receipt][:amount]
      money_receipt.taxable_value = params[:demand_money_receipt][:taxable_value]
      money_receipt.cheque_number = params[:demand_money_receipt][:cheque_number]
      if params[:other_bank_name] == nil 
       money_receipt.bank_name = params[:demand_money_receipt][:bank_name]
      else
        money_receipt.bank_name = params[:other_bank_name]
      end
      money_receipt.instrument_date = params[:demand_money_receipt][:instrument_date]
      money_receipt.payment_mode = params[:demand_money_receipt][:payment_mode]
      money_receipt.remarks = params[:demand_money_receipt][:remarks]
      money_receipt.save

      flash[:success]='Money Receipt Generated successfully.'
      redirect_to demand_demand_money_receipt_index_url      
    else
      flash[:danger]='Money Receipt is not Generated because of Duplicacy.'
      redirect_to demand_demand_money_receipt_index_url
    end
  else
    money_receipt=DemandMoneyReceipt.new
    booking=Booking.find(params[:demand_money_receipt][:booking_id].to_i)
    money_receipt_serial=MoneyReceiptSerial.find_by(business_unit_id: booking.cost_sheet.flat.block.business_unit_id)
    if money_receipt_serial != nil
      money_receipt.serial=money_receipt_serial.last+1
      money_receipt_serial.update(last: money_receipt_serial.last+1)
    end
    money_receipt.booking_id = params[:demand_money_receipt][:booking_id]
    money_receipt.date = params[:demand_money_receipt][:date]
    money_receipt.amount = params[:demand_money_receipt][:amount]
    money_receipt.taxable_value = params[:demand_money_receipt][:taxable_value]
    money_receipt.cheque_number = params[:demand_money_receipt][:cheque_number]
    if params[:other_bank_name] == nil 
     money_receipt.bank_name = params[:demand_money_receipt][:bank_name]
    else
      money_receipt.bank_name = params[:other_bank_name]
    end
    money_receipt.instrument_date = params[:demand_money_receipt][:instrument_date]
    money_receipt.payment_mode = params[:demand_money_receipt][:payment_mode]
    money_receipt.remarks = params[:demand_money_receipt][:remarks]
    money_receipt.save

    flash[:success]='Money Receipt Generated successfully.'
    redirect_to demand_demand_money_receipt_index_url    
  end
# to be saved in demand_money_receipts with booking_id (date, amount, remarks, bank name and chq no to be created)
end

def demand_money_receipt_edit
	@money_receipt=DemandMoneyReceipt.find(params[:format])
    @customer_with_flats=[]
	Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |booking|
		@customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.id]]
	end
	@bank_names=['HDFC', 'ICICI', 'YES', 'SBI', 'Axis']
	@payment_modes=['NEFT', 'RTGS', 'CHEQUE', 'CASH', 'ONLINE TRANSFER']
end

def demand_money_receipt_update
	money_receipt=DemandMoneyReceipt.new
	money_receipt.booking_id = params[:demand_money_receipt][:booking_id]
	money_receipt.date = params[:demand_money_receipt][:date]
	money_receipt.amount = params[:demand_money_receipt][:amount]
	money_receipt.cheque_number = params[:demand_money_receipt][:cheque_number]
	money_receipt.bank_name = params[:demand_money_receipt][:bank_name]
	money_receipt.instrument_date = params[:demand_money_receipt][:instrument_date]
  money_receipt.taxable_value = params[:demand_money_receipt][:taxable_value]
	money_receipt.payment_mode = params[:demand_money_receipt][:payment_mode]
	money_receipt.remarks = params[:demand_money_receipt][:remarks]
  money_receipt.serial = params[:demand_money_receipt][:serial]
	money_receipt.save
	
	@old_money_receipt=DemandMoneyReceipt.find(params[:old_money_receipt_id])
	@old_money_receipt.destroy

	flash[:success]='Money Receipt Updated successfully.'
  redirect_to demand_demand_money_receipt_index_url    
end

def demand_money_receipt_destroy
	@money_receipt=DemandMoneyReceipt.find(params[:format])
    @money_receipt.destroy

   	flash[:success]='Money Receipt deleted successfully.'
    redirect_to demand_demand_money_receipt_index_url     
end

def demand_preview_index
	@ledger_entry_header=LedgerEntryHeader.find(params[:format])	
end

def demand_money_receipt_preview_index
	@demand_money_receipt=DemandMoneyReceipt.find(params[:format])
end

def demand_money_receipt_with_gst_preview_index
	@demand_money_receipt_with_gst=DemandMoneyReceipt.find(params[:format])
end

def demand_download_mail
  @ledger_entry_header_id=params[:ledger_entry_header_id]
  @demand_pdf=render_to_string(:partial => "demand_preview_index", :layout => false, :locals => { :ledger_entry_header_id => @ledger_entry_header_id})
  @demand_pdf='<html><body>'+@demand_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@demand_pdf)
  if params[:download]=='Download'
    send_data(@pdf, filename: 'Demand.pdf', type: 'application/pdf')
  elsif params[:email]=='Email'
    data=[@ledger_entry_header_id,@pdf, current_personnel]
    UserMailer.send_demand(data).deliver
    flash[:success]='Email sent successfully.'
    redirect_to :back
  elsif params[:whatsapp]=='Whatsapp'
    whatsapp_pdf=Base64.encode64(@pdf) 
    whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
    lead = LedgerEntryHeader.find(@ledger_entry_header_id.to_i).booking.cost_sheet.lead
    urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.mobile))
    result = HTTParty.get(urlstring)
    if result.parsed_response['result'] != 'not exists'            
      urlstring =  "https://eu71.chat-api.com/instance"+(LedgerEntryHeader.find(@ledger_entry_header_id.to_i).booking.cost_sheet.lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(LedgerEntryHeader.find(@ledger_entry_header_id.to_i).booking.cost_sheet.lead.personnel.organisation.whatsapp_key)
      result = HTTParty.get(urlstring,
       :body => { :phone => "91"+(lead.mobile),
                  :body => whatsapp_pdf,
                  :filename => 'Demand.pdf' 
                  }.to_json,
       :headers => { 'Content-Type' => 'application/json' } )
      urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
      result = HTTParty.get(urlstring,
       :body => { :phone => "91"+(current_personnel.mobile),
                  :body => whatsapp_pdf,
                  :filename => 'Demand.pdf' 
                  }.to_json,
       :headers => { 'Content-Type' => 'application/json' } )

      flash[:success]='Whatsapp send successfully.'
    else 
      urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.other_number))
      result = HTTParty.get(urlstring)
      if result.parsed_response['result'] != 'not exists'
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(lead.mobile),
                  :body => whatsapp_pdf,
                  :filename => 'Demand.pdf' 
                  }.to_json,
       :headers => { 'Content-Type' => 'application/json' } )
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(current_personnel.mobile),
                  :body => whatsapp_pdf,
                  :filename => 'Demand.pdf' 
                  }.to_json,
       :headers => { 'Content-Type' => 'application/json' } )

        flash[:success]='Whatsapp send successfully.'
      else
        flash[:danger]='Number not active on Whatsapp'  
      end
    end
    redirect_to demand_report_demand_bill_register_url
  end
end

def demand_gst_money_receipt_download_mail
  @demand_money_receipt_id=params[:demand_money_receipt_id]
  @demand_money_receipt_pdf=render_to_string(:partial => "demand_money_receipt_with_gst_preview_index", :layout => false, :locals => { :demand_money_receipt_id => @demand_money_receipt_id})
  @demand_money_receipt_pdf='<html><body>'+@demand_money_receipt_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@demand_money_receipt_pdf)
  if params[:download]=='Download'
      send_data(@pdf, filename: 'Demand MoneyReceipt.pdf', type: 'application/pdf')
  elsif params[:email]=='Email'
      data=[@demand_money_receipt_id,@pdf,current_personnel]
      UserMailer.send_demand_money_receipt(data).deliver
      flash[:success]='Email send successfully.'
      redirect_to demand_demand_money_receipt_index_url
  elsif params[:Whatsapp]=='Whatsapp'
      lead = Lead.find(DemandMoneyReceipt.find(@demand_money_receipt_id.to_i).booking.cost_sheet.lead_id)
      urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.mobile))
      result = HTTParty.get(urlstring)
      whatsapp_pdf=Base64.encode64(@pdf) 
      whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
      if result.parsed_response['result'] != 'not exists'            
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(lead.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand Money Receipt.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(current_personnel.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Demand Money Receipt.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )

        flash[:success]='Whatsapp send successfully.'
      else 
        if lead.other_number == nil || lead.other_number == ''
          flash[:danger]='Other Number is nil for this customer so whatsapp cannot be send'  
        else
          urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.other_number))
          result = HTTParty.get(urlstring)
          if result.parsed_response['result'] != 'not exists'
            urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
            result = HTTParty.get(urlstring,
             :body => { :phone => "91"+(lead.other_number),
                        :body => whatsapp_pdf,
                        :filename => 'Demand Money Receipt.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )
            urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
            result = HTTParty.get(urlstring,
             :body => { :phone => "91"+(current_personnel.mobile),
                        :body => whatsapp_pdf,
                        :filename => 'Demand Money Receipt.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )

            flash[:success]='Whatsapp send successfully.'
          else
            flash[:danger]='Number not active on Whatsapp'  
          end
        end
      end
    redirect_to demand_demand_money_receipt_index_url
  end
end

def demand_money_receipt_download_mail
  @demand_money_receipt_id=params[:demand_money_receipt_id]
  @demand_money_receipt_pdf=render_to_string(:partial => "demand_money_receipt_preview_index", :layout => false, :locals => { :demand_money_receipt_id => @demand_money_receipt_id})
  @demand_money_receipt_pdf='<html><body>'+@demand_money_receipt_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@demand_money_receipt_pdf)
  if params[:download]=='Download'
    send_data(@pdf, filename: 'Demand MoneyReceipt.pdf', type: 'application/pdf')
  elsif params[:email]=='Email'
    data=[@demand_money_receipt_id,@pdf,current_personnel]
    UserMailer.send_demand_money_receipt(data).deliver
    flash[:success]='Email send successfully.'
    redirect_to demand_demand_money_receipt_index_url
  elsif params[:Whatsapp]=='Whatsapp'
    lead = Lead.find(DemandMoneyReceipt.find(@demand_money_receipt_id.to_i).booking.cost_sheet.lead_id)
    urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
    result = HTTParty.get(urlstring,
     :body => { :phone => "91"+(lead.mobile),
                :body => @pdf,
                :filename => 'Demand money receipt.pdf' 
                }.to_json,
     :headers => { 'Content-Type' => 'application/json' } )
    flash[:success]='Whatsapp send successfully.'
    redirect_to demand_demand_money_receipt_index_url
  end
end

def bookings
  @blocks=[]
  BusinessUnit.where(organisation_id: current_personnel.organisation_id).each do |business_unit|
    business_unit.blocks.each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name, block.id]]
    end
  end
  if params[:block_id] == nil
	  @bookings=Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id})
  else
    @selected_block_id = params[:block_id]
    @bookings=Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:blocks => {id: @selected_block_id.to_i})
  end
end

def adhoc_demand_form
	@booking=Booking.find(params[:booking_id])
	@milestones=[]
	@booking.cost_sheet.payment_plan.milestones.each do |milestone|
		@milestones+=[[milestone.payment_milestone.description, milestone.id]]
	end
end

def generate_adhoc_demand
  if params[:milestone_ids] == nil
    flash[:danger]='Demand cannot be generated because of no milestone selected.'
    booking_id={'booking_id' => params[:booking_id]}
    redirect_to controller: 'demand', action: 'adhoc_demand_form', params: booking_id
  else
  	ledger_entry_header=LedgerEntryHeader.new
  	ledger_entry_header.booking_id=params[:booking_id]
  	ledger_entry_header.date=params[:demand][:date]
  	ledger_entry_header.save
  	
  	params[:milestone_ids].each do |milestone_id|
  		ledger_entry_item=LedgerEntryItem.new
  		ledger_entry_item.milestone_id=milestone_id
  		ledger_entry_item.ledger_entry_header_id=ledger_entry_header.id
  		ledger_entry_item.save
  	end

  	redirect_to :controller => "demand", :action => "bookings"
  end
end

def time_driven_demand_due
end

def generate_time_driven_demand
#generate time driven demand
end

def cancellation_form
	@customer_with_flats=[]
	Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |booking|
		@customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.id]]
	end
	@customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
end

def cancel
  adhoc_charge = AdhocCharge.find(params[:adhoc_charge_id].to_i)
  adhoc_charge_entry = AdhocChargeEntry.new
  adhoc_charge_entry.booking_id = params[:adhoc_charge_entry][:booking_id]
  adhoc_charge_entry.adhoc_charge_id = adhoc_charge.id
  adhoc_charge_entry.date = params[:adhoc_charge_entry][:date]
  adhoc_charge_entry.amount = params[:adhoc_charge_entry][:amount]
  adhoc_charge_entry.remarks = params[:adhoc_charge_entry][:remarks]
  adhoc_charge_entry.save

  booking = Booking.find(adhoc_charge_entry.booking_id)
  booking.update(cancelled: true, cancellation_date: adhoc_charge_entry.date)

  Lead.find(booking.cost_sheet.lead_id).update(cancelled_on: adhoc_charge_entry.date)

  flash[:success]='Flat Cancelled Successfully.'
  redirect_to flat_index_flat_index_url  
end

def adhoc_charge_entry
	@customer_with_flats=[]
	Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |booking|
		@customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.id]]
	end
	@customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
	@adhoc_charges=selections(AdhocCharge, :description)
end

def adhoc_charge
	adhoc_charge=AdhocChargeEntry.new
	adhoc_charge.booking_id = params[:adhoc_charge_entry][:booking_id]
	adhoc_charge.adhoc_charge_id = params[:adhoc_charge_entry][:adhoc_charge_id]
	adhoc_charge.date = params[:adhoc_charge_entry][:date]
	adhoc_charge.amount = params[:adhoc_charge_entry][:amount]
	adhoc_charge.remarks = params[:adhoc_charge_entry][:remarks]
	adhoc_charge.save

	flash[:success]='Adhoc Charge Entry Done.'
	redirect_to adhoc_charge_adhoc_charge_register_url
end

def adhoc_charge_edit
	@adhoc_charge_entry=AdhocChargeEntry.find(params[:format])
	@customer_with_flats=[]
	Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |booking|
		@customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.id]]
	end
	@customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
	@adhoc_charges=selections(AdhocCharge, :description)
end

def adhoc_charge_update
	adhoc_charge_entry=AdhocChargeEntry.find(params[:adhoc_charge_entry_id])
	adhoc_charge_entry.update(booking_id: params[:adhoc_charge_entry][:booking_id], adhoc_charge_id: params[:adhoc_charge_entry][:adhoc_charge_id], date: params[:adhoc_charge_entry][:date], remarks: params[:adhoc_charge_entry][:remarks], amount: params[:adhoc_charge_entry][:amount])
	
	flash[:success]='Adhoc Charge Entry Updated.'
	redirect_to adhoc_charge_adhoc_charge_register_url
end

def adhoc_charge_destroy
	@adhoc_charge_entry=AdhocChargeEntry.find(params[:format])
	@adhoc_charge_entry.destroy

	flash[:success]='Adhoc Charge Entry Deleted successfully.'
	redirect_to adhoc_charge_adhoc_charge_register_url
end

def credit_note_entry
	@customer_with_flats=[]
	Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |booking|
		@customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.id]]
	end
	@customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
	@credit_note_heads=selections(CreditNoteHead, :description)
end

def credit_note
	credit_note=CreditNoteEntry.new
	credit_note.booking_id = params[:credit_note_entry][:booking_id]
	credit_note.credit_note_head_id = params[:credit_note_entry][:credit_note_head_id]
	credit_note.date = params[:credit_note_entry][:date]
	credit_note.amount = params[:credit_note_entry][:amount]
	credit_note.remarks = params[:credit_note_entry][:remarks]
	credit_note.save

	flash[:success]='Credit Note Entry Done.'
	redirect_to credit_note_head_credit_note_register_url
end

def credit_note_edit
	@credit_note_entry=CreditNoteEntry.find(params[:format])
	@customer_with_flats=[]
	Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |booking|
		@customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.id]]
	end
	@customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
	@credit_note_heads=selections(AdhocCharge, :description)
end

def credit_note_update
	credit_note_entry=CreditNoteEntry.find(params[:credit_note_entry_id])
	credit_note_entry.update(booking_id: params[:credit_note_entry][:booking_id], credit_note_head_id: params[:credit_note_entry][:credit_note_head_id], date: params[:credit_note_entry][:date], remarks: params[:credit_note_entry][:remarks], amount: params[:credit_note_entry][:amount])
	
	flash[:success]='Credit Note Entry Updated.'
	redirect_to credit_note_head_credit_note_register_url
end

def credit_note_destroy
	@credit_note_entry=CreditNoteEntry.find(params[:format])
	@credit_note_entry.destroy

	flash[:success]='Credit Note Entry Deleted successfully.'
	redirect_to credit_note_head_credit_note_register_url
end

def booking_date_edit
	@booking=Booking.find(params[:format])
end

def booking_date_update
	@booking= Booking.find(params[:booking_id])
  if params[:booking][:date] == nil
  else
    @booking.update(date: params[:booking][:date])
  end
  if params[:booking][:agreement_date] == nil
  else
    @booking.update(agreement_date: params[:booking][:agreement_date])
  end
  if params[:booking][:mortgage_noc_date] == nil
  else
    @booking.update(mortgage_noc_date: params[:booking][:mortgage_noc_date])
  end
  if params[:booking][:allotment_date] == nil
  else
    @booking.update(allotment_date: params[:booking][:allotment_date])
  end
    
  flash[:success]='Booking updated successfully.'
	redirect_to demand_bookings_url
end


def construction_linked_demand_generation_form
  @business_units = selections(BusinessUnit, :name)
  if params[:business_unit_id] == nil
    @selected_business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    payment_plans=PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
    @payment_milestones=[]
    payment_plans.each do |payment_plan|
      payment_plan.construction_linked_milestones.sort_by{|x| x.order}.each do |milestone|
        @payment_milestones+=[milestone.payment_milestone]
      end
    end
    @payment_milestones=@payment_milestones.uniq
    @blocks=Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
  else
    @selected_business_unit_id = params[:business_unit_id]
    payment_plans=PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id, id: @selected_business_unit_id.to_i})
    @payment_milestones=[]
    payment_plans.each do |payment_plan|
      payment_plan.construction_linked_milestones.sort_by{|x| x.order}.each do |milestone|
        @payment_milestones+=[milestone.payment_milestone]
      end
    end
    @payment_milestones=@payment_milestones.uniq
    @blocks=Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id, id: @selected_business_unit_id.to_i})
  end
  





# payment milestone t plus edit and block level and floor level edit option to be given  
# using dream one to pilot
# payment_plans=PaymentPlan.where(business_unit: 2)
# # all payment milestones existing in the above payment plans block wise and floor wise
# @payment_milestones=[]
# payment_plans.each do |payment_plan|
#   payment_plan.construction_linked_milestones.sort_by{|x| x.order}.each do |milestone|
#     @payment_milestones+=[milestone.payment_milestone]
#   end
# end
# @payment_milestones=@payment_milestones.uniq
# # all blocks existing in the project
# @blocks=Block.where(business_unit_id: 2)
end

def generate_construction_linked_demand
  if params[:block_wise_demand_details]==nil
    floor_wise_demand_details = params[:floor_wise_demand_details]
    selected_business_unit_id = params[:selected_business_unit_id]
    position_1 = floor_wise_demand_details.index('*')
    position_2 = floor_wise_demand_details.index('%')
    position_3 = floor_wise_demand_details.index('$')
    block_id = floor_wise_demand_details[0..position_1-1]
    floor = floor_wise_demand_details[position_1+1..position_2-1]
    payment_milestone_id = floor_wise_demand_details[position_2+1..position_3-1]
    block = Block.where(id: block_id.to_i, business_unit_id: selected_business_unit_id.to_i)[0]
    flats = Flat.where(block_id: block.id, floor: floor.to_i)
    business_unit = BusinessUnit.find(selected_business_unit_id.to_i)
    
    achieved_milestone=AchievedMilestone.new
    achieved_milestone.block_id = block.id.to_i
    achieved_milestone.payment_milestone_id = payment_milestone_id.to_i
    achieved_milestone.floor = floor.to_i
    achieved_milestone.date = DateTime.now
    achieved_milestone.demand_raised = true
    achieved_milestone.save

    payement_milestone = PaymentMilestone.where(organisation_id: achieved_milestone.block.business_unit.organisation_id, id: payment_milestone_id.to_i)
    flats.each do |flat|
      booking = Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id})[0]
      ledger_entry_header = LedgerEntryHeader.new
      ledger_entry_header.booking_id = booking.id
      ledger_entry_header.date = DateTime.now
      ledger_entry_header.save
      
      payment_milestone.milestones.each do |milestone|
        ledger_entry_item=LedgerEntryItem.new
        ledger_entry_item.milestone_id=milestone.id
        ledger_entry_item.ledger_entry_header_id=ledger_entry_header.id
        ledger_entry_item.save
      end
    end
  elsif params[:floor_wise_demand_details]==nil
    block_wise_demand_details = params[:block_wise_demand_details]
    selected_business_unit_id = params[:selected_business_unit_id]
    position_1 = block_wise_demand_details.index('*')
    position_2 = block_wise_demand_details.index('$')
    block_id = block_wise_demand_details[0..position_1-1]
    payment_milestone_id = block_wise_demand_details[position_1+1..position_2-1]
    block = Block.where(id: block_id.to_i, business_unit_id: selected_business_unit_id.to_i)[0]
    
    achieved_milestone=AchievedMilestone.new
    achieved_milestone.block_id = block.id
    achieved_milestone.payment_milestone_id = payment_milestone_id.to_i
    achieved_milestone.date = DateTime.now
    achieved_milestone.demand_raised = true
    achieved_milestone.save

    payement_milestone = PaymentMilestone.where(organisation_id: achieved_milestone.block.business_unit.organisation_id, id: payment_milestone_id.to_i)
    flats = Flat.where(block_id: block.id)
    flats.each do |flat|
      booking = Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id})[0]
      ledger_entry_header = LedgerEntryHeader.new
      ledger_entry_header.booking_id = booking.id
      ledger_entry_header.date = DateTime.now
      ledger_entry_header.save
      
      payment_milestone.milestones.each do |milestone|
        ledger_entry_item=LedgerEntryItem.new
        ledger_entry_item.milestone_id=milestone.id
        ledger_entry_item.ledger_entry_header_id=ledger_entry_header.id
        ledger_entry_item.save
      end
    end
  end

  redirect_to demand_construction_linked_demand_generation_form_url
end

def credit_note_preview_index
  @credit_note = CreditNoteEntry.find(params[:format])
end

def demand_credit_note_download_mail
  @credit_note_id=params[:credit_note_id]
  @credit_note_pdf=render_to_string(:partial => "credit_note_preview_index", :layout => false, :locals => { :credit_note_id => @credit_note_id})
  @credit_note_pdf='<html><body>'+@credit_note_pdf+'</body></html>'
  @pdf = WickedPdf.new.pdf_from_string(@credit_note_pdf)
  if params[:download]=='Download'
    send_data(@pdf, filename: 'Credit Note.pdf', type: 'application/pdf')
  elsif params[:email]=='Email'
    data=[@credit_note_id,@pdf,current_personnel]
    UserMailer.send_credit_note(data).deliver
    flash[:success]='Email send successfully.'
    redirect_to credit_note_head_credit_note_register_url
  elsif params[:Whatsapp]=='Whatsapp'
    lead = Lead.find(CreditNoteEntry.find(@credit_note_id.to_i).booking.cost_sheet.lead_id)
    urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
    result = HTTParty.get(urlstring,
     :body => { :phone => "91"+(lead.mobile),
                :body => @pdf,
                :filename => 'Credit Note.pdf' 
                }.to_json,
     :headers => { 'Content-Type' => 'application/json' } )
    flash[:success]='Whatsapp send successfully.'
    redirect_to demand_credit_note_index_url
  end  
end

  def milestone_wise_report
    if params[:business_unit] == "Dream One 1/2" || params[:business_unit] == "Dream One 3/4"
      business_unit = BusinessUnit.find_by_name("Dream One")
    else
      business_unit = BusinessUnit.find_by_name(params[:business_unit])
    end
    block_level_milestones = PaymentMilestone.where(organisation_id: business_unit.organisation_id, block_level: true).map{|x| x.description}
    floor_level_milestones = PaymentMilestone.where(organisation_id: business_unit.organisation_id, floor_level: true).map{|x| x.description}
    @final_data = {}
    Block.where(business_unit_id: business_unit.id).each do |block|
      if params[:business_unit] == "Dream One 1/2"
        if block.name == "Block-1" || block.name == "Block-2"
          block_wise_data = {}
          floor_wise_data = {}
          floor_ids = Flat.where(block_id: block.id).map{|x| x.floor}
          floor_ids = floor_ids.sort.uniq
          floor_ids.each do |floor_id|
            flat_wise_milestone_amount = {}
            Flat.where(block_id: block.id, floor: floor_id).each do |flat|
              if Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id}).where(cancelled: true) != [] || Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id}).where(cancelled: nil) == []
              else
                booking = Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id})[0]
                Milestone.where(payment_plan_id: booking.cost_sheet.payment_plan_id).each do |milestone|
                  if floor_level_milestones.include?(milestone.payment_milestone.description) == true
                    if booking.demand_generated(milestone) == false
                      if flat_wise_milestone_amount[milestone.payment_milestone.description] == nil
                        flat_wise_milestone_amount[milestone.payment_milestone.description] = booking.cost_sheet.milestone_amount(milestone.id)
                      else
                        flat_wise_milestone_amount[milestone.payment_milestone.description] += booking.cost_sheet.milestone_amount(milestone.id)
                      end
                    end
                  elsif block_level_milestones.include?(milestone.payment_milestone.description) == true
                    if booking.demand_generated(milestone) == false
                      if block_wise_data[milestone.payment_milestone.description] == nil
                        block_wise_data[milestone.payment_milestone.description] = booking.cost_sheet.milestone_amount(milestone.id)
                      else
                        block_wise_data[milestone.payment_milestone.description] += booking.cost_sheet.milestone_amount(milestone.id)
                      end
                    end
                  end
                end
              end
            end
            floor_wise_data[floor_id] = flat_wise_milestone_amount
          end
          @final_data[block.name] = [block_wise_data, floor_wise_data]
        end
      elsif params[:business_unit] == "Dream One 3/4"
        if block.name == "Block-3" || block.name == "Block-4"
          block_wise_data = {}
          floor_wise_data = {}
          floor_ids = Flat.where(block_id: block.id).map{|x| x.floor}
          floor_ids = floor_ids.sort.uniq
          floor_ids.each do |floor_id|
            flat_wise_milestone_amount = {}
            Flat.where(block_id: block.id, floor: floor_id).each do |flat|
              if Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id}).where(cancelled: true) != [] || Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id}).where(cancelled: nil) == []
              else
                booking = Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id})[0]
                Milestone.where(payment_plan_id: booking.cost_sheet.payment_plan_id).each do |milestone|
                  if floor_level_milestones.include?(milestone.payment_milestone.description) == true
                    if booking.demand_generated(milestone) == false
                      p block.name
                      p booking.cost_sheet.lead.name
                      p booking.cost_sheet.lead.id
                      p milestone.payment_milestone.description
                      p booking.cost_sheet.milestone_amount(milestone.id)
                      p "=============floor level==============="
                      if flat_wise_milestone_amount[milestone.payment_milestone.description] == nil
                        flat_wise_milestone_amount[milestone.payment_milestone.description] = booking.cost_sheet.milestone_amount(milestone.id)
                      else
                        flat_wise_milestone_amount[milestone.payment_milestone.description] += booking.cost_sheet.milestone_amount(milestone.id)
                      end
                    end
                  elsif block_level_milestones.include?(milestone.payment_milestone.description) == true
                    if booking.demand_generated(milestone) == false
                      p block.name
                      p booking.cost_sheet.lead.name
                      p booking.cost_sheet.lead.id
                      p milestone.payment_milestone.description
                      p booking.cost_sheet.milestone_amount(milestone.id)
                      p "=============block level==============="
                      if block_wise_data[milestone.payment_milestone.description] == nil
                        block_wise_data[milestone.payment_milestone.description] = booking.cost_sheet.milestone_amount(milestone.id)
                      else
                        block_wise_data[milestone.payment_milestone.description] += booking.cost_sheet.milestone_amount(milestone.id)
                      end
                    end
                  end
                end
              end
            end
            floor_wise_data[floor_id] = flat_wise_milestone_amount
          end
          @final_data[block.name] = [block_wise_data, floor_wise_data]
        end
      else
        block_wise_data = {}
        floor_wise_data = {}
        floor_ids = Flat.where(block_id: block.id).map{|x| x.floor}
        floor_ids = floor_ids.sort.uniq
        floor_ids.each do |floor_id|
          flat_wise_milestone_amount = {}
          Flat.where(block_id: block.id, floor: floor_id).each do |flat|
            if Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id}).where(cancelled: true) != [] || Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id}).where(cancelled: nil) == []
            else
              booking = Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: flat.id})[0]
              Milestone.where(payment_plan_id: booking.cost_sheet.payment_plan_id).each do |milestone|
                if floor_level_milestones.include?(milestone.payment_milestone.description) == true
                  if booking.demand_generated(milestone) == false
                    if flat_wise_milestone_amount[milestone.payment_milestone.description] == nil
                      flat_wise_milestone_amount[milestone.payment_milestone.description] = booking.cost_sheet.milestone_amount(milestone.id)
                    else
                      flat_wise_milestone_amount[milestone.payment_milestone.description] += booking.cost_sheet.milestone_amount(milestone.id)
                    end
                  end
                elsif block_level_milestones.include?(milestone.payment_milestone.description) == true
                  if booking.demand_generated(milestone) == false
                    if block_wise_data[milestone.payment_milestone.description] == nil
                      block_wise_data[milestone.payment_milestone.description] = booking.cost_sheet.milestone_amount(milestone.id)
                    else
                      block_wise_data[milestone.payment_milestone.description] += booking.cost_sheet.milestone_amount(milestone.id)
                    end
                  end
                end
              end
            end
          end
          floor_wise_data[floor_id] = flat_wise_milestone_amount
        end
        @final_data[block.name] = [block_wise_data, floor_wise_data]
      end
    end
  end

end
