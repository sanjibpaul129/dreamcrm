class ElectricalReportController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:collection_feed]

  def collection_feed
    collection=[]
    total=0
    ['Dream Exotica', 'Dream Palazzo', 'Dream Valley', 'Dream Eco City'].each do |project|
    business_unit=BusinessUnit.find_by_name(project)  
      7.times do |count|
      total=0  
      from=(Time.now-count.month).beginning_of_month
      to=(Time.now-count.month).end_of_month  
      money_receipts=ElectricalMoneyReceipt.includes(:flat => [:block]).where(:blocks => {business_unit_id: business_unit.id}).where('electrical_money_receipts.date >= ? and electrical_money_receipts.date <= ?', from, to)       
        money_receipts.each do |money_receipt|
          total+=money_receipt.amount
        end
      collection+=[total.round]  
      end
    end
    render text: collection.to_s 
  end 


  def outstanding_electric_bill_index
  	if params[:business_unit]==nil
      @flats=Flat.includes(:block =>[:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'}).where.not(lead_id: nil)
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id = params[:business_unit][:business_unit_id]
      @business_units=selections(BusinessUnit, :name)
      @flats=Flat.includes(:block =>[:business_unit]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where.not(lead_id: nil)      
    end
  end

  def individual_customer_electric_ledger
    @flat_id=params[:format]
    @electrical_bills=ElectricalBill.where(flat_id: @flat_id.to_i)
    @flat=Flat.find(params[:format])
    @electrical_money_receipts=ElectricalMoneyReceipt.where(flat_id: @flat_id.to_i)
    @both_documents=@electrical_bills+@electrical_money_receipts
    @both_documents=@both_documents.sort_by{|document| document.date}
  end

  def outstanding_electrical_reminder
    flat_ids = params[:flat_ids]
    whatsapps_sent = 0
    sent_customers = ''
    whatsapps_sent_to_customers = ''
    flat_ids.each do |flat|
      data = Flat.find(flat.to_i)
      lead = Lead.find(data.lead_id)
      if params[:commit] == 'No Reminder'
        flat = Flat.find(flat.to_i)
        flat.update(no_reminder: true)
        sent_customers = 'No Reminder marking done.'  
      elsif params[:commit] == '7d Reminder'
        flat = Flat.find(flat.to_i)
        flat.update(no_reminder: nil)
        sent_customers = '7 Days Reminder markind done.'
      elsif params[:commit] == '3d Reminder'
        flat = Flat.find(flat.to_i)
        flat.update(no_reminder: false)
        sent_customers = '3 Days Reminder marking done.'
      elsif params[:commit] == 'Send E-mail Reminder'
        if lead.email == nil || lead.email == ''
        else
          UserMailer.bulk_outstanding_reminder(data).deliver
          reminder_log = ReminderLog.new
          reminder_log.flat_id = flat.to_i
          reminder_log.sent_on = DateTime.now
          reminder_log.save
        end
        sent_customers = 'Email Reminder sent successfully.'  
      elsif params[:commit] == 'Send Whatsapp Reminder'
        if lead.mobile == nil || lead.mobile == '' || whatsapps_sent > 5
        else
          message = 'Dear '+lead.name.to_s+",\n"+'Your payment amounting to Rs.'+(data.outstanding).to_s+' for your apartment '+data.name.to_s+"-"+(data.block.name)+', in '+(data.block.business_unit.name)+' is due. Kindly make the payment at the earliest to avoid any complication or extra charges.'+"\n"+"\n"+'Regards,' +"\n"+"Rupsa Banerjee"+"\n"+"9007576657"+"\n"+'The Jain Group'
          urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
            customer_result = HTTParty.post(urlstring,
               :body => { :to_number => '+91'+lead.mobile,
                 :message => message,    
                  :type => "text"
                  }.to_json,
                  :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
          whatsapps_sent += 1 
          reminder_log = ReminderLog.new
          reminder_log.flat_id = flat.to_i
          reminder_log.sent_on = DateTime.now
          reminder_log.whatsapp = true
          reminder_log.save
          if customer_result["sent"]
            if whatsapps_sent_to_customers == ''
              whatsapps_sent_to_customers += 'WhatsApp sent successfully to:'+"\n"+lead.name+"\n"
            else
              whatsapps_sent_to_customers += lead.name+"\n"
            end
            sent_customers += 'WhatsApp sent successfully to:'+lead.name
          end
          sleep(3)
        end
      end
    end
    if whatsapps_sent_to_customers == ''
    else
      urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
      result = HTTParty.post(urlstring,
         :body => { :to_number => '+91'+current_personnel.mobile,
           :message => whatsapps_sent_to_customers,    
            :type => "text"
            }.to_json,
            :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
    end

    flash[:success] = sent_customers
    redirect_to :back
  end

   def electrical_reminder_log_index
    if params[:business_unit]==nil
      @electrical_reminder_logs=ElectricalReminderLog.includes(:flat => [:block => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:electrical_reminder_log][:from]
      @business_units=selections(BusinessUnit, :name)
      @to=params[:electrical_reminder_log][:to]
      @electrical_reminder_logs=ElectricalReminderLog.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where('electrical_reminder_logs.sent_on >= ? and electrical_reminder_logs.sent_on <= ?', @from, @to)  
    end
   end

   def electrical_bill_register
    if params[:business_unit]==nil
      @electrical_bills=ElectricalBill.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:electrical_bill][:from]
      @to=params[:electrical_bill][:to]
      @business_units=selections(BusinessUnit, :name)
      @electrical_bills=ElectricalBill.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where('electrical_bills.date >= ? and electrical_bills.date<= ?', @from, @to)  
    end
   end

   def electrical_money_receipt_register
    if params[:business_unit]==nil
      @electrical_money_receipts=ElectricalMoneyReceipt.includes(:flat => [:block => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'})
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @from=params[:electrical_money_receipt][:from]
      @to=params[:electrical_money_receipt][:to]
      @business_units=selections(BusinessUnit, :name)
      @electrical_money_receipts=ElectricalMoneyReceipt.includes(:flat => [:block =>[:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id,id: @business_unit_id.to_i}).where('electrical_money_receipts.date >= ? and electrical_money_receipts.date <= ?', @from, @to)
    end
   end

   def bulk_electrical_bill_delete
    params[:electrical_bill_ids].each do |electrical_bill_id|
      ElectricalBill.find(electrical_bill_id).destroy
    end

    flash[:success]='Bulk electrical Bill deleted successfully'
    redirect_to electrical_report_electrical_bill_register_url
  end

  def bulk_electrical_money_receipt_delete
    params[:electrical_money_receipt_ids].each do |electrical_money_receipt_id|
      ElectricalMoneyReceipt.find(electrical_money_receipt_id).destroy
    end

    flash[:success]='Bulk electrical money_receipt deleted successfully'
    redirect_to electrical_report_electrical_money_receipt_register_url
  end

end
