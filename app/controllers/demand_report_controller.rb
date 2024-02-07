class DemandReportController < ApplicationController
	def demand_outstanding_report
    if current_personnel.organisation_id == 6
      if params[:block]== nil
        @blocks=[]
        Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
          @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
        end
        @bookings=Booking.includes(:cost_sheet => [:flat => [:block => [:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'JSB Jyoti Residency'}, :blocks => {id: 38}).where(ignore: nil)
      else
        @blocks=[]
        Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
          @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
        end
        @block_id = params[:block][:block_id]
        @bookings=Booking.includes(:cost_sheet => [:flat => [:block => [:business_unit]]]).where(:blocks => {id: @block_id.to_i}).where(ignore: nil)
      end
    else
      if params[:business_unit]==nil
        @bookings=Booking.includes(:cost_sheet => [:flat => [:block => [:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'}).where(ignore: nil)
        @business_units=selections(BusinessUnit, :name)
        @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
      else
        @business_units=selections(BusinessUnit, :name)
        @business_unit_id = params[:business_unit][:business_unit_id]
        @bookings=Booking.includes(:cost_sheet => [:flat => [:block => [:business_unit]]]).where(:business_units => {id: @business_unit_id.to_i}).where(ignore: nil)
      end  
    end
	end

  def populate_blocks
    business_unit_id = (params[:business_unit_id]).to_i
    @blocks=[]
    Block.where(business_unit_id: business_unit_id).each do |block|
      @blocks += [[block.name, block.id]]
    end

    respond_to do |format|
      format.js { render :action => "populate_blocks"}
    end
  end

  def individual_customer_demand_ledger
    @booking_id=params[:format]
    @ledger_entry_headers=LedgerEntryHeader.where(booking_id: @booking_id.to_i)
    @booking=Booking.find(params[:format])
    @adhoc_charge_entries=AdhocChargeEntry.where(booking_id: @booking_id.to_i)

    @demand_money_receipts=DemandMoneyReceipt.where(booking_id: @booking_id.to_i)
    @credit_note_entries=CreditNoteEntry.where(booking_id: @booking_id.to_i)
    @both_documents=@ledger_entry_headers+@adhoc_charge_entries+@demand_money_receipts+@credit_note_entries
    @both_documents=@both_documents.sort_by{|document| document.date}
  end

  def demand_letter_with_breakup
    @booking_id=params[:format]
    @ledger_entry_headers=LedgerEntryHeader.where(booking_id: @booking_id.to_i)
    @booking=Booking.find(params[:format])
    @adhoc_charge_entries=AdhocChargeEntry.where(booking_id: @booking_id.to_i)
    @demand_money_receipts=DemandMoneyReceipt.where(booking_id: @booking_id.to_i)
    @credit_note_entries=CreditNoteEntry.where(booking_id: @booking_id.to_i)
    @both_documents=@ledger_entry_headers+@adhoc_charge_entries+@demand_money_receipts+@credit_note_entries
    @both_documents=@both_documents.sort_by{|document| document.date}
  end

  def individual_customer_demand_ledger_detailed
    @booking_id=params[:format]
    @ledger_entry_headers=LedgerEntryHeader.where(booking_id: @booking_id.to_i)
    @booking=Booking.find(params[:format])
    
    @demand_money_receipts=DemandMoneyReceipt.where(booking_id: @booking_id.to_i)
    @both_documents=@ledger_entry_headers+@demand_money_receipts
    @both_documents=@both_documents.sort_by{|document| document.date}
  end

  def outstanding_submit
    if params[:commit]=='Whatsapp Reminder'
      redirect_to controller: 'demand_report', action: 'demand_whatsapp_reminder', params: request.request_parameters 
    elsif params[:commit]=='Send E-mail Reminder'
      redirect_to controller: 'demand_report', action: 'demand_outstanding_reminder', params: request.request_parameters 
    elsif params[:commit]=='Ignore'
      redirect_to controller: 'demand_report', action: 'demand_outstanding_ignore', params: request.request_parameters 
    elsif params[:commit]=='No Reminder'
      booking_ids = params[:booking_ids]
      booking_ids.each do |booking_id|
        booking=Booking.find(booking_id.to_i)
        flat=Flat.find(booking.cost_sheet.flat.id)
        flat.update(no_reminder: true)
      end
      flash[:success]='No Reminder Marking Done.'
      redirect_to demand_report_demand_outstanding_report_url    
    elsif params[:commit]=='7d Reminder'
      booking_ids = params[:booking_ids]
      booking_ids.each do |booking_id|
        booking=Booking.find(booking_id.to_i)
        flat=Flat.find(booking.cost_sheet.flat.id)
        flat.update(no_reminder: nil)
      end
      flash[:success]='7d Reminder Marked'
      redirect_to demand_report_demand_outstanding_report_url
    elsif params[:commit]=='3d Reminder'
      booking_ids = params[:booking_ids]
      booking_ids.each do |booking_id|
        booking=Booking.find(booking_id.to_i)
        flat=Flat.find(booking.cost_sheet.flat.id)
        flat.update(no_reminder: false)
    end
      flash[:success]='3d Reminder Marked'
      redirect_to demand_report_demand_outstanding_report_url
    end
  end

  def demand_outstanding_reminder
    booking_ids = params[:booking_ids]
    not_send_customers=''
    booking_ids.each do |id|
      data=Booking.find(id.to_i)
      if data.cost_sheet.lead.email == nil || data.cost_sheet.lead.email == ''
        not_send_customers += data.cost_sheet.lead.name+","+" "
      else
        lead=Lead.find(data.cost_sheet.lead_id)
        if lead.email==nil || lead.email==''
        else
          if Booking.find(id.to_i).demand_outstanding <=100000
          else
            UserMailer.demand_outstanding_reminder([current_personnel,data]).deliver
            demand_reminder_log=DemandReminderLog.new
            demand_reminder_log.booking_id = id.to_i
            demand_reminder_log.sent_on = DateTime.now
            demand_reminder_log.save
          end
        end
      end
    end
    if not_send_customers == []
      flash[:success]='Email Reminder sent successfully.'
    else
      flash[:danger]='Email not sent to these customers'+not_send_customers.to_s
    end
    redirect_to demand_report_demand_outstanding_report_url
  end

  def demand_whatsapp_reminder
    sent_customers=''
    booking_ids = params[:booking_ids]
    booking_ids[0..5].each do |id|
      data=Booking.find(id.to_i)
      lead=Lead.find(data.cost_sheet.lead_id)
      flat=data.cost_sheet.flat
      if current_personnel.organisation_id == 6
        message="\n"+'Dear '+lead.name+",\n"+'A payment of Rs.'+"#{data.demand_outstanding.to_s.gsub(/(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?/, "\\1,")}/-"+' of your apartment '+flat.full_name+', in '+(lead.business_unit.name)+' is due. Request you to kindly pay the same at the earliest.'+"\n"+'Ignore if already paid.'+"\n"+"\n"+'Warm Regards,'+"\n"+'JSB Infrastructures' 
      else
        message='Dear '+lead.name+",\n"+'Your payment amounting to Rs.'+data.demand_outstanding.to_s+' for your apartment '+flat.full_name+', in '+(lead.business_unit.name)+' is due. Kindly make the payment at the earliest to avoid any complication or extra charges.'+"\n"+"\n"+'Regards,' +"\n"+current_personnel.name+"\n"+current_personnel.mobile+"\n"+'The Jain Group' 
      end
        
      if lead.mobile==nil || lead.mobile==''
      else
        # if Booking.find(id.to_i).demand_outstanding <=100000
        # else

          urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                      customer_result = HTTParty.post(urlstring,
                         :body => { :to_number => '+91'+(lead.mobile),
                           :message => message,    
                            :type => "text"
                            }.to_json,
                            :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    

          # urlstring =  "https://eu71.chat-api.com/instance"+(current_personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(current_personnel.organisation.whatsapp_key)
          # customer_result = HTTParty.get(urlstring,
          #  :body => { :phone => '91'+(lead.mobile),
          #             :body => message 
          #             }.to_json,
          #  :headers => { 'Content-Type' => 'application/json' } )

          if customer_result["sent"]
            sent_customers+='WhatsApp sent successfully to:'+lead.name
            if current_personnel.organisation_id == 6
              if flat.chat_id==nil
                 urlstring =  "https://eu71.chat-api.com/instance"+(current_personnel.organisation.whatsapp_instance)+"/group?token="+(current_personnel.organisation.whatsapp_key)
                     result = HTTParty.get(urlstring,
                 :body => { :phones => [('91'+current_personnel.mobile)],
                           :groupName => (lead.name+' '+lead.mobile)[0..20],  
                           :messageText => 'Greetings from JSB Infrastructures! ' +message
                           }.to_json,
                :headers => { 'Content-Type' => 'application/json' } )
                flat.update(chat_id: result.parsed_response['chatId'])
              else
                urlstring =  "https://eu71.chat-api.com/instance"+(current_personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(current_personnel.organisation.whatsapp_key)
                customer_result = HTTParty.get(urlstring,
                 :body => { :chatId => flat.chat_id,
                            :body => 'Greetings from JSB Infrastructures! ' +message 
                            }.to_json,
                 :headers => { 'Content-Type' => 'application/json' } )

              end
            else
              if flat.chat_id==nil
                #  urlstring =  "https://eu71.chat-api.com/instance"+(current_personnel.organisation.whatsapp_instance)+"/group?token="+(current_personnel.organisation.whatsapp_key)
                #      result = HTTParty.get(urlstring,
                #  :body => { :phones => [('91'+current_personnel.mobile)],
                #            :groupName => (lead.name+' '+lead.mobile)[0..20],  
                #            :messageText => 'Jain-e: ' +message
                #            }.to_json,
                # :headers => { 'Content-Type' => 'application/json' } )
                # flat.update(chat_id: result.parsed_response['chatId'])
              else
                # urlstring =  "https://eu71.chat-api.com/instance"+(current_personnel.organisation.whatsapp_instance)+"/sendMessage?token="+(current_personnel.organisation.whatsapp_key)
                # customer_result = HTTParty.get(urlstring,
                #  :body => { :chatId => flat.chat_id,
                #             :body => 'Jain-e: ' +message 
                #             }.to_json,
                #  :headers => { 'Content-Type' => 'application/json' } )

              end
            end    
          else
            sent_customers="sent"
            # sent_customers+='Ooops!!! WhatsApp unable to sent due to '+result["message"]+' to '+ lead.name.to_s 
          end
        # end
      end
    end
    
    flash[:success]=sent_customers
    redirect_to demand_report_demand_outstanding_report_url
  end

  def demand_outstanding_ignore
    booking_ids = params[:booking_ids]
    booking_ids.each do |id|
      booking = Booking.find(id.to_i)
      booking.update(ignore: true)
    end

    flash[:success]='Ignore marking successfully.'
    redirect_to demand_report_demand_outstanding_report_url
  end

  def demand_reminder_log_index
    if params[:business_unit]==nil
      @reminder_logs=DemandReminderLog.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:reminder_log][:from]
      @business_units=selections(BusinessUnit, :name)
      @to=params[:reminder_log][:to]
      @reminder_logs=DemandReminderLog.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where('demand_reminder_logs.sent_on >= ? and demand_reminder_logs.sent_on <= ?', @from, @to)  
    end
  end

  def demand_ledger_download_and_mail
    @booking_id=params[:booking_id]
    @ledger_entry_headers=LedgerEntryHeader.where(booking_id: @booking_id.to_i)
    @adhoc_charge_entries=AdhocChargeEntry.where(booking_id: @booking_id.to_i)
    @demand_money_receipts=DemandMoneyReceipt.where(booking_id: @booking_id.to_i)
    @credit_note_entries=CreditNoteEntry.where(booking_id: @booking_id.to_i)
    @both_documents=@ledger_entry_headers+@adhoc_charge_entries+@demand_money_receipts+@credit_note_entries
    @both_documents=@both_documents.sort_by{|document| document.date}
    @demand_ledger_pdf=render_to_string(:partial => "individual_customer_demand_ledger", :layout => false, :locals => { :booking_id => @booking_id})
    @demand_ledger_pdf='<html><body>'+@demand_ledger_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@demand_ledger_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'Demand Ledger.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        data=[@pdf, @booking_id, current_personnel]
        UserMailer.demand_ledger(data).deliver
        flash[:success]='Email send successfully.'
        redirect_to :back
    elsif params[:whatsapp]=='Whatsapp'
      lead = Lead.find(Booking.find(params[:booking_id].to_i).cost_sheet.lead_id)
      urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/checkPhone?token="+(lead.personnel.organisation.whatsapp_key)+"&phone="+('91'+(lead.mobile))
      result = HTTParty.get(urlstring)
      whatsapp_pdf=Base64.encode64(@pdf) 
      whatsapp_pdf='data:application/pdf;base64,'+whatsapp_pdf
      if result.parsed_response['result'] != 'not exists'            
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(lead.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Applicant Ledger.pdf' 
                    }.to_json,
         :headers => { 'Content-Type' => 'application/json' } )
        urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
        result = HTTParty.get(urlstring,
         :body => { :phone => "91"+(current_personnel.mobile),
                    :body => whatsapp_pdf,
                    :filename => 'Applicant Ledger.pdf' 
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
                        :filename => 'Applicant Ledger.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )
            urlstring =  "https://eu71.chat-api.com/instance"+(lead.personnel.organisation.whatsapp_instance)+"/sendFile?token="+(lead.personnel.organisation.whatsapp_key)
            result = HTTParty.get(urlstring,
             :body => { :phone => "91"+(current_personnel.mobile),
                        :body => whatsapp_pdf,
                        :filename => 'Applicant Ledger.pdf' 
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )

            flash[:success]='Whatsapp send successfully.'
          else
            flash[:danger]='Number not active on Whatsapp'  
          end
        end
      end
      redirect_to :back
    end
  end

  def breakup_demand_letter_download_and_mail
    @booking_id=params[:booking_id]
    @ledger_entry_headers=LedgerEntryHeader.where(booking_id: @booking_id.to_i)
    @adhoc_charge_entries=AdhocChargeEntry.where(booking_id: @booking_id.to_i)
    @demand_money_receipts=DemandMoneyReceipt.where(booking_id: @booking_id.to_i)
    @credit_note_entries=CreditNoteEntry.where(booking_id: @booking_id.to_i)
    @both_documents=@ledger_entry_headers+@adhoc_charge_entries+@demand_money_receipts+@credit_note_entries
    @both_documents=@both_documents.sort_by{|document| document.date}
    @demand_ledger_pdf=render_to_string(:partial => "demand_letter_with_breakup", :layout => false, :locals => { :booking_id => @booking_id})
    @demand_ledger_pdf='<html><body>'+@demand_ledger_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@demand_ledger_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'Demand Ledger.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        data=[@pdf, @booking_id, current_personnel]
        UserMailer.demand_ledger(data).deliver
        flash[:success]='Email send successfully.'
        redirect_to :back
    end
  end

  def breakup_demand_ledger_download_and_mail
    @ledger_entry_header_id=params[:ledger_entry_header_id]
    @ledger_entry_headers=LedgerEntryHeader.where(id: @ledger_entry_header_id.to_i)
    @demand_ledger_pdf=render_to_string(:partial => "milestone_invoice_preview", :layout => false, :locals => { :ledger_entry_header_id => @ledger_entry_header_id})
    @demand_ledger_pdf='<html><body>'+@demand_ledger_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@demand_ledger_pdf)
    if params[:commit]=='Download'
        send_data(@pdf, filename: 'Demand Ledger.pdf', type: 'application/pdf')
    elsif params[:commit]=='Email'
        data=[@pdf, @booking_id, current_personnel]
        UserMailer.demand_ledger(data).deliver
        flash[:success]='Email send successfully.'
        # redirect_to :back
    end
    redirect_to demand_report_ledger_entry_header_index_url
  end

  def demand_bill_register
    if params[:business_unit]==nil
      @ledger_entry_headers=LedgerEntryHeader.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:bookings => {ignore: nil}).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @business_units=selections(BusinessUnit, :name)
      @ledger_entry_headers=LedgerEntryHeader.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:bookings => {ignore: nil}).where(:business_units => {id: @business_unit_id.to_i})
    end
  end

  def demand_money_receipt_register
    if params[:business_unit]==nil
      @money_receipts=DemandMoneyReceipt.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:bookings => {ignore: nil}).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:demand_money_receipt][:from]
      @to=params[:demand_money_receipt][:to]
      @business_units=selections(BusinessUnit, :name)
      @money_receipts=DemandMoneyReceipt.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {organisation_id: current_personnel.organisation_id,id: @business_unit_id.to_i}).where('demand_money_receipts.date >= ? and demand_money_receipts.date <= ?', @from, @to)       
    end
  end

  def multi_money_receipt_delete
    demand_money_receipts = DemandMoneyReceipt.find(params[:money_receipt_ids])
    demand_money_receipts.each do |demand_money_receipt|
      demand_money_receipt.destroy
    end

    flash[:success]='All Money Receipts Deleted successfully.'
    redirect_to demand_report_demand_money_receipt_index_url
  end

  def demand_money_receipt_preview_index
    @money_receipt=DemandMoneyReceipt.find(params[:format])
    balance_received=@money_receipt.amount
    previous_money_receipts=DemandMoneyReceipt.where(booking_id: @money_receipt.booking_id).where('date < ?', @money_receipt.date)
    money_received_till_date=0
    previous_money_receipts.each do |previous_money_receipt|
      money_received_till_date+=previous_money_receipt.amount
    end
    previous_demands=LedgerEntryHeader.where(booking_id: @money_receipt.booking_id).where('date < ?', @money_receipt.date)
    @remaining_demands={}
      previous_demands.sort_by{|x| x.date}.each do |previous_demand|
        if previous_demand.amount<=money_received_till_date
          money_received_till_date=money_received_till_date-previous_demand.amount
        else
          if balance_received >= previous_demand.amount-money_received_till_date
          @remaining_demands[previous_demand]=previous_demand.amount-money_received_till_date
          balance_received=balance_received-(previous_demand.amount-money_received_till_date)
          elsif balance_received != 0
          @remaining_demands[previous_demand]=balance_received
          balance_received=0  
          end
          money_received_till_date=0
        end
      end
  end

  def demand_money_receipt_download
    @money_receipt_id=params[:money_receipt_id]
    @money_receipt_pdf=render_to_string(:partial => "demand_money_receipt_preview_index", :layout => false, :locals => { :money_receipt_id => @money_receipt_id})
    @money_receipt_pdf='<html><body>'+@money_receipt_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@money_receipt_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'Money Receipt.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        data=[@pdf]
        UserMailer.demand_money_receipt(data).deliver

        # money_receipt = DemandMoneyReceipt.find(params[:money_receipt_id])
        # money_receipt.update(mailed_on: DateTime.now)
        
        flash[:success]='Email send successfully.'
        redirect_to demand_report_demand_money_receipt_index_url
    end
  end


  def ledger_entry_header_index
    if params[:business_unit]==nil
      @ledger_entry_headers=LedgerEntryHeader.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
      @block_id=nil
      @blocks=[]
      Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
        @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
      end
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @block_id=params[:block][:block_id]
      @from=params[:ledger_entry_header][:from]
      @business_units=selections(BusinessUnit, :name)
      @to=params[:ledger_entry_header][:to]
      @blocks=[]
      Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
        @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
      end
      @ledger_entry_headers=LedgerEntryHeader.includes(:booking => [:cost_sheet => [:flat => [:block =>[:business_unit]]]]).where(:blocks => {id: @block_id.to_i, business_unit_id: @business_unit_id.to_i}).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('ledger_entry_headers.date >= ? and ledger_entry_headers.date <= ?', @from, @to)  
    end
  end

  def milestone_invoice_preview
    @ledger_entry_header=LedgerEntryHeader.find(params[:format])
  end

  def ledger_entry_header_date_edit
    @ledger_entry_header=LedgerEntryHeader.find(params[:format])
  end

  def ledger_entry_header_date_update
    @ledger_entry_header=LedgerEntryHeader.find(params[:ledger_entry_header_id])
    @ledger_entry_header.update(date: params[:ledger_entry_header][:date])

    flash[:success]='Demand Date Updated successfully.'
    redirect_to demand_report_ledger_entry_header_index_url
  end

  def demand_money_receipt_submit
    if params[:commit]=='View Details'
      redirect_to controller: 'demand_report', action: 'demand_money_receipt_register', params: request.request_parameters 
    elsif params[:commit]=='Last 6 month status'
      redirect_to controller: 'demand_report', action: 'demand_collection_graph', params: request.request_parameters 
    end
  end

  def demand_collection_graph    
    @business_unit_id=params[:business_unit][:business_unit_id]
    demand_money_receipts_hash={}
    demand_money_receipts_data=[]
    demand_money_receipts_hash[:name]='Demand Money Receipts'
    month_count=5 
    @months=[]

    count=6
    6.times do
      @months=@months+[Date::MONTHNAMES[((Time.now)-(month_count.months)).month]]
      year=((Time.now)-(month_count.months)).year
      month=((Time.now)-(month_count.months)).month
     # DemandMoneyReceipt.includes(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('demand_money_receipts.created_at >= ? and demand_money_receipts.created_at <= ?', last_six_month, DateTime.now.end_of_month)
      demand_money_receipts_data+=[DemandMoneyReceipt.joins(:booking => [:cost_sheet => [:flat => [:block => [:business_unit]]]]).where(:business_units => {organisation_id: current_personnel.organisation_id, id: @business_unit_id}).where("extract(year from demand_money_receipts.created_at) = ? AND extract(month from demand_money_receipts.created_at) = ?", year, month).count]  
      month_count=month_count-1
    end
    demand_money_receipts_hash[:data]=demand_money_receipts_data
    @series=[demand_money_receipts_hash].to_json.html_safe
    @months=@months.to_json.html_safe
  end
  
  def demand_destroy
    @ledger_entry_header=LedgerEntryHeader.find(params[:format])
    @ledger_entry_header.ledger_entry_items.destroy_all
    @ledger_entry_header.destroy

    flash[:success]='Demand Deleted successfully.'
    redirect_to demand_report_ledger_entry_header_index_url
  end

  def multi_demand_destroy
    ledger_entry_headers = LedgerEntryHeader.find(params[:ledger_entry_header_ids])
    ledger_entry_headers.each do |ledger_entry_header|
      ledger_entry_header.ledger_entry_items.destroy_all
      ledger_entry_header.destroy
    end

    flash[:success]='All Demand Deleted successfully.'
    redirect_to demand_report_ledger_entry_header_index_url
  end

  def ignore_demand_index
    @bookings=Booking.includes(:cost_sheet => [:flat => [:block => [:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(ignore: true)
  end

  def restore_demands
    params[:booking_ids].each do |booking_id|
      booking=Booking.find(booking_id)
      booking.update(ignore: nil)
    end

    flash[:success]='Demands Restores successfully.'
    redirect_to demand_report_ignore_demand_index_url
  end

  def demand_notice_index
    @ledger_entry_header = LedgerEntryHeader.find(params[:format])
  end

  def demand_notice_download_mail
    @ledger_entry_header_id=params[:ledger_entry_header_id]
    @demand_notice_pdf=render_to_string(:partial => "demand_notice_index", :layout => false, :locals => { :ledger_entry_header_id => @ledger_entry_header_id})
    @demand_notice_pdf='<html><body>'+@demand_notice_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@demand_notice_pdf)
    if params[:commit]=='Download'
        send_data(@pdf, filename: 'Demand Notice.pdf', type: 'application/pdf')
    elsif params[:commit]=='Email'
        data=[@pdf, @ledger_entry_header_id, current_personnel]
        UserMailer.demand_notice(data).deliver
        flash[:success]='Email send successfully.'
        redirect_to demand_report_demand_bill_register_url
    end
  end

  def future_demand_index
    @business_units=selections(BusinessUnit, :name)
    if params[:business_unit] == nil
    else
      @business_unit_id = params[:business_unit][:business_unit_id]
      @payment_plans = PaymentPlan.where(business_unit_id: params[:business_unit][:business_unit_id])
      @blocks=Block.where(business_unit_id: @business_unit_id.to_i)
    end
  end

  def demand_money_receipt_destroy
    demand_money_receipt = DemandMoneyReceipt.find(params[:format])
    demand_money_receipt.destroy

    flash[:success]='Demand Money Receipt Deleted Successfully'
    redirect_to demand_report_demand_money_receipt_register_url
  end

  def multi_demand_money_receipt_destroy
    params[:money_receipt_ids].each do |money_receipt_id|
      demand_money_receipt = DemandMoneyReceipt.find(money_receipt_id.to_i)
      demand_money_receipt.destroy
    end

    flash[:success]='Demand Money Receipt Deleted Successfully'
    redirect_to demand_report_demand_money_receipt_register_url
  end

  def demand_accrued_interest
    @customer_with_flats=[]
    
    bookings=Booking.includes(:cost_sheet => [:flat => [:block =>[:business_unit]]]).where(:business_units => {organisation_id: current_personnel.organisation_id})
    bookings.each do |booking|
    @customer_with_flats+=[[booking.cost_sheet.lead.name+'-'+booking.cost_sheet.flat.full_name, booking.cost_sheet.flat.id]]
    end  
    @customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
    
    if params[:flat_id] == nil
    else
      booking = Booking.includes(:cost_sheet).where(:cost_sheets => {flat_id: params[:flat_id].to_i})[0]
      @ledger_entry_items = LedgerEntryItem.includes(:ledger_entry_header).where(:ledger_entry_headers => {booking_id: booking.id}).sort_by{|x| x.created_at}
      @demand_money_receipts = DemandMoneyReceipt.where(booking_id: booking.id).sort_by{|x| x.date}
      # @ledger_entry_items.each do |ledger_entry_item|
      #   milestone_amount=ledger_entry_item.ledger_entry_header.booking.cost_sheet.milestone_amount(ledger_entry_item.milestone_id)
      #   @demand_money_receipts.each do |demand_money_receipt|
      #     if demand_money_receipt.date <= ledger_entry_item.ledger_entry_header.date+15.days
      #       payment_date = nil
      #       pending_amount = milestone_amount-demand_money_receipt.amount
      #       milestone_amount = milestone_amount-demand_money_receipt.amount
      #     else
      #       if payment_date == nil
      #         payment_date = ledger_entry_header.date
      #       end
      #       if milestone_amount <= 0
      #         carry_forward_amount =  pending_amount
      #       else
      #         pending_amount = milestone_amount-demand_money_receipt.amount
      #         milestone_amount = milestone_amount-demand_money_receipt.amount
      #         pending_from = (payment_date.to_date.beginning_of_day-demand_money_receipt.date.beginning_of_day).to_i
      #         payment_date = demand_money_receipt.date
      #       end
      #     end
      #   end
      # end
    end
  end

  def area_unit_wise_demand_index
    @area_wise_data={}
    @unit_wise_data={}
    total_area = {}
    total_flats ={}
    total_flat_count = 0
    sold_flat_count = 0
    BusinessUnit.where(organisation_id: current_personnel.organisation_id).each do |business_unit|
      if Flat.includes(:block).where(:blocks => {business_unit_id: business_unit.id}) == []
      else
        Flat.includes(:block).where(:blocks => {business_unit_id: business_unit.id}).each do |flat|
          total_flats["Total Flats"] = total_flat_count += 1
          if total_area["Total Area"] == nil
            total_area["Total Area"] = flat.SBA
          else
            total_area["Total Area"] += flat.SBA
          end
          if flat.lead_id == nil || flat.lead_id == ''
            if total_area["Sold Area"] == nil
              total_area["Sold Area"] = 0
            else
              total_area["Sold Area"] += 0
            end
          else
            total_falts["Sold Flats"] = sold_flat_count += 1
            if total_area["Sold Area"] == nil
              total_area["Sold Area"] = flat.SBA
            else
              total_area["Sold Area"] += flat.SBA
            end
          end
        end
        if total_flats["Sold Flats"] == nil
          total_flats["Sold Flats"] = 0
        end
        total_flats["Unsold Flats"] = total_flats["Total Flats"].to_i-total_flats["Sold Flats"].to_i
        total_flats["Sold %"] = (total_flats["Sold Flats"].to_i/total_flats["Total Flats"].to_i)*100
        
        total_area["Unsold Area"] = total_area["Total Area"].to_i-total_area["Sold Area"].to_i
        total_area["Sold %"] = (total_area["Sold Area"].to_i/total_area["Total Area"].to_i)*100
        @area_wise_data[business_unit.name] = total_area
        @unit_wise_data[business_unit.name] = total_flats
      end
    end
  end
end