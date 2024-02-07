class MaintainanceBillController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:maintenance_outstanding_feed]
  
  def maintainance_bill_index
  	@maintainance_bills=MaintainenceBill.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: ''})
  end
  
  def maintainance_bill_new
  	@maintainance_bill=MaintainenceBill.new
    @business_units=selections(BusinessUnit, :name)
    @maintainance_bill_action='maintainance_bill_create'
  end

  def maintainance_bill_create
    @flats=[]
    Flat.includes(:block).where(:blocks => {business_unit_id: params[:business_unit_id]}).each do |flat|
      if flat.individual_bill_generation == nil || flat.individual_bill_generation == false
        if flat.lead_id != nil
            @flats+=[flat]
        end
      end
    end
    from=params[:maintainence_bill][:from]    
    to=params[:maintainence_bill][:to]
    duplicate_flats=[]
    @flats.each do |flat|
      from_duplicate=MaintainenceBill.where(flat_id: flat.id).where('"from" <= ? and "to" >= ?', from, from)
      to_duplicate=MaintainenceBill.where(flat_id: flat.id).where('"from" <= ? and "to" >= ?', to, to)
      duplicate = from_duplicate+to_duplicate
      if duplicate != []
        duplicate_flats+=[flat.name]
      else
        @maintainance_bills=MaintainenceBill.new(maintainance_bill_params)
        @maintainance_bills.flat_id = flat.id
        lead=Flat.where(id: flat.id)[0]
        @maintainance_bills.lead_id = lead.lead_id
        maintenance_bill_serial=MaintenanceBillSerial.find(1)
        @maintainance_bills.serial=maintenance_bill_serial.last+1
        maintenance_bill_serial.update(last: maintenance_bill_serial.last+1)
        @maintainance_bills.save    
        @maintainance_bills.update(amount: ((@maintainance_bills.bill_amount)*1.18).round)
      end
    end
    if duplicate_flats != []
      flash[:danger]=duplicate_flats
    else
      flash[:success]='Bill Generated successfully.'
    end
  	redirect_to maintainance_bill_maintainance_bill_index_url
  end
  
  def maintainance_bill_edit
  	@maintainance_bill=MaintainenceBill.find(params[:format])
    @maintainance_bill_action='maintainance_bill_update'
  end
  
  def maintainance_bill_update
  	@maintainance_bill= MaintainenceBill.find(params[:maintainance_bill_id])
  	@maintainance_bill.update(maintainance_bill_params)
    @maintainance_bill.update(amount: ((@maintainance_bill.bill_amount)*1.18).round)
    flash[:success]='Bill updated successfully.'
  	redirect_to maintainance_bill_maintainance_bill_index_url
  end
  
  def maintainance_bill_destroy
  	@maintainance_bill=MaintainenceBill.find(params[:format])
  	@maintainance_bill.destroy

    flash[:success]='Bill destroyed successfully.'
  	redirect_to maintainance_bill_maintainance_bill_index_url
  end

  def maintainance_bill_preview_index
    @maintainance_bill=MaintainenceBill.find(params[:format])
  end

  def maintainance_bill_tax_invoice_index
    @maintainance_bill=MaintainenceBill.find(params[:format])
  end

  def maintainance_bill_tax_invoice_download
    @maintainance_bill_id=params[:maintainance_bill_id]
    @maintainance_bill_pdf=render_to_string(:partial => "maintainance_bill_tax_invoice_index", :layout => false, :locals => { :maintainance_bill_id => @maintainance_bill_id})
    @maintainance_bill_pdf='<html><body>'+@maintainance_bill_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@maintainance_bill_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'MaintainenceBill.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        maintenance_bill=MaintainenceBill.find(@maintenance_bill_id.to_i)
        data=[@pdf, maintenance_bill]
        UserMailer.maintainance_bill(data).deliver

        maintainance_bill = MaintainenceBill.find(params[:maintainance_bill_id])
        maintainance_bill.update(mailed_on: DateTime.now)

        flash[:success]='Email send successfully.'
        redirect_to maintainance_bill_maintainance_bill_index_url
    end
  end

  def maintainance_bill_pdf_converter
  maintainance_bill_ids=params[:maintainance_bill_ids]
    maintainance_bill_ids.each do |maintainance_bill_id|
      maintainance_bill=MaintainenceBill.find(maintainance_bill_id)
      @maintainance_bill_pdf=render_to_string(:partial => "maintainance_bill_preview_index", :layout => false, :locals => { :maintainance_bill_id => maintainance_bill.id})
      @maintainance_bill_pdf='<html><body>'+@maintainance_bill_pdf+'</body></html>'
      @pdf = WickedPdf.new.pdf_from_string(@maintainance_bill_pdf)
      data=[@pdf, maintainance_bill]
      if Lead.find(maintainance_bill.lead_id).email==nil || Lead.find(maintainance_bill.lead_id).email==''
      else
      UserMailer.maintainance_bill(data).deliver      
      maintainance_bill.update(mailed_on: DateTime.now)
      end

    end

  flash[:success]='Email send successfully.'
  redirect_to maintainance_bill_maintainance_bill_index_url
  end

  def maintainance_bill_download
    @maintainance_bill_id=params[:maintainance_bill_id]
    @maintainance_bill_pdf=render_to_string(:partial => "maintainance_bill_preview_index", :layout => false, :locals => { :maintainance_bill_id => @maintainance_bill_id})
    @maintainance_bill_pdf='<html><body>'+@maintainance_bill_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@maintainance_bill_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'MaintainenceBill.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        maintenance_bill=MaintainenceBill.find(@maintainance_bill_id.to_i)
        data=[@pdf, maintenance_bill]
        UserMailer.maintainance_bill(data).deliver

        maintainance_bill = MaintainenceBill.find(params[:maintainance_bill_id])
        maintainance_bill.update(mailed_on: DateTime.now)

        flash[:success]='Email send successfully.'
        redirect_to maintainance_bill_maintainance_bill_index_url
    end
  end

  def individual_maintainance_bill_index
    @maintainance_bills=MaintainenceBill.includes(:flat => [:block => [:business_unit]]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where(:flats => {individual_bill_generation: true})
  end

  def individual_maintainance_bill_new
    @individual_maintainance_bill=MaintainenceBill.new
    @business_units=selections(BusinessUnit, :name)
    @individual_maintainance_bill_action='individual_maintainance_bill_create'
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.block.name+'-'+flat.full_name, flat.id]]
      end
    end
    @customer_with_flats=@customer_with_flats.sort_by{|x,y| x}  
  end

  def individual_maintainance_bill_create
    flat = Flat.where(id: params[:flat_id].to_i)[0]
    # @maintainance_bill=MaintainenceBill.new(individual_maintainance_bill_params)
    # @maintainance_bill.flat_id = flat.id
    # @maintainance_bill.lead_id = flat.lead_id
    # @maintainance_bill.save  
    # from=@maintainance_bill.from.to_date
    # to=@maintainance_bill.to.to_date
    # month=(to.month-from.month)
    # days = (from.end_of_month - from).to_f+1
    # amount_daily = (((@maintainance_bill.lead.area.to_f*@maintainance_bill.rate.to_f)+867+867)/from.end_of_month.day.to_f)*days
    # amount_monthly = ((@maintainance_bill.lead.area.to_f*@maintainance_bill.rate.to_f)+867+867)*month.to_f
    # total_amount = (amount_daily+amount_monthly).round
    # @maintainance_bill.update(amount: total_amount)

    # flash[:success]='Bill Generated successfully.'
    # redirect_to maintainance_bill_individual_maintainance_bill_index_url

    from=params[:maintainence_bill][:from]    
    to=params[:maintainence_bill][:to]
    duplicate_flats=[]
  
    from_duplicate=MaintainenceBill.where(flat_id: flat.id).where('"from" <= ? and "to" >= ?', from, from)
    to_duplicate=MaintainenceBill.where(flat_id: flat.id).where('"from" <= ? and "to" >= ?', to, to)
    duplicate = from_duplicate+to_duplicate
    if duplicate != []
      duplicate_flats =[flat.name]
    else
      @maintainance_bill=MaintainenceBill.new(individual_maintainance_bill_params)
      @maintainance_bill.flat_id = flat.id
      @maintainance_bill.lead_id = flat.lead_id
      maintenance_bill_serial=MaintenanceBillSerial.find(1)
      @maintainance_bill.serial=maintenance_bill_serial.last+1
      maintenance_bill_serial.update(last: maintenance_bill_serial.last+1)
      @maintainance_bill.save  
      @maintainance_bill.update(amount: ((@maintainance_bill.bill_amount)*1.18).round)
    end
    if duplicate_flats != []
      flash[:danger]='bill is duplicate for this customer'
    else
      flash[:success]='Bill Generated successfully.'
    end
    redirect_to maintainance_bill_individual_maintainance_bill_index_url

  end

  def individual_maintainance_bill_edit
    @individual_maintainance_bill=MaintainenceBill.find(params[:format])
    @individual_maintainance_bill_action='individual_maintainance_bill_update'
  end
  
  def individual_maintainance_bill_update
    @individual_maintainance_bill= MaintainenceBill.find(params[:maintainance_bill_id])
    @individual_maintainance_bill.update(individual_maintainance_bill_params)
    @individual_maintainance_bill.update(amount: ((@individual_maintainance_bill.bill_amount)*1.18).round)
    flash[:success]='Bill updated successfully.'
    redirect_to maintainance_bill_individual_maintainance_bill_index_url
  end
  
  def individual_maintainance_bill_destroy
    @individual_maintainance_bill=MaintainenceBill.find(params[:format])
    @individual_maintainance_bill.destroy

    flash[:success]='Bill destroyed successfully.'
    redirect_to maintainance_bill_individual_maintainance_bill_index_url
  end

  def money_receipt_index
    @money_receipts=MoneyReceipt.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: ''})
  end

  def money_receipt_new
    @money_receipt=MoneyReceipt.new
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.block.name+'-'+flat.full_name, flat.id]]
      end
    end
    @customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
    @money_receipt_action='money_receipt_create'
  end

  def money_receipt_create
    @money_receipts=MoneyReceipt.new(money_receipt_params)  
    lead=Flat.where(id: params[:money_receipt][:flat_id])[0]
    @money_receipts.lead_id=lead.lead_id
    @money_receipts.save
    
    flash[:success]='Money Receipt Generated successfully.'
    redirect_to maintainance_bill_money_receipt_index_url    
  end

  def money_receipt_edit
    @money_receipt=MoneyReceipt.find(params[:format])
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.block.name+'-'+flat.full_name, flat.id]]
      end
    end
    @money_receipt_action='money_receipt_update'
  end

  def money_receipt_update
    @money_receipt= MoneyReceipt.find(params[:money_receipt_id])
    lead=Flat.where(id: params[:money_receipt][:flat_id])[0]
    @money_receipt.lead_id=lead.lead_id
    @money_receipt.update(money_receipt_params)

    flash[:success]='Money Receipt updated successfully.'
    redirect_to maintainance_bill_money_receipt_index_url    
  end

  def money_receipt_destroy
    @money_receipt=MoneyReceipt.find(params[:format])
    @money_receipt.destroy

    flash[:success]='Money Receipt destroyed successfully.'
    redirect_to maintainance_bill_money_receipt_index_url
  end

  def money_receipt_preview_index
    @money_receipt=MoneyReceipt.find(params[:format])
  end

  def money_receipt_pdf_converter
    money_receipt_ids=params[:money_receipt_ids]
    money_receipt_ids.each do |money_receipt|
      money_receipt=MoneyReceipt.find(money_receipt)
      @money_receipt_pdf=render_to_string(:partial => "money_receipt_preview_index", :layout => false, :locals => { :money_receipt_id => money_receipt.id})
      @money_receipt_pdf='<html><body>'+@money_receipt_pdf+'</body></html>'
      @pdf = WickedPdf.new.pdf_from_string(@money_receipt_pdf)
      data=[@pdf, money_receipt]
      UserMailer.money_receipt(data).deliver      
      money_receipt.update(mailed_on: DateTime.now)
    end

    flash[:success]='Email send successfully.'
    redirect_to maintainance_bill_money_receipt_index_url
  end

def money_receipt_download
    @money_receipt_id=params[:money_receipt_id]
    @money_receipt_pdf=render_to_string(:partial => "money_receipt_preview_index", :layout => false, :locals => { :money_receipt_id => @money_receipt_id})
    @money_receipt_pdf='<html><body>'+@money_receipt_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@money_receipt_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'Money Receipt.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        money_receipt=MoneyReceipt.find(@money_receipt_id.to_i)
        data=[@pdf, money_receipt]
        UserMailer.money_receipt(data).deliver

        money_receipt = MoneyReceipt.find(params[:money_receipt_id])
        money_receipt.update(mailed_on: DateTime.now)
        
        flash[:success]='Email send successfully.'
        redirect_to maintainance_bill_money_receipt_index_url
    end
end

  def populate_rate
      @business_unit_id=params[:id]
      @rate= MaintainenceCharge.find_by_business_unit_id(@business_unit_id).rate
      respond_to do |format|
          format.js { render :action => "populate_rate"}
      end
  end

  def populate_individual_rate
    @business_unit_id=params[:id]
      @rate= MaintainenceCharge.find_by_business_unit_id(@business_unit_id).rate
      respond_to do |format|
          format.js { render :action => "populate_individual_rate"}
      end
  end

  def customer_with_flat_index
    if params[:business_unit]==nil
      @flats=Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'}).where.not(lead_id: nil)
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @business_units=selections(BusinessUnit, :name)
      @flats=Flat.includes(:block =>[:business_unit]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where.not(lead_id: nil)
    end  
  end

  def individual_remarks
    @flat=Flat.find(params[:format])
    @flat_action='flat_remarks'
  end

  def flat_remarks
    flat = Flat.find(params[:flat_id])
    flat.update(remarks: params[:remarks])

    flash[:success]=' remarks updated successfully'
    redirect_to maintainance_bill_customer_with_flat_index_url
  end

  # def customer_with_flat_submit
  #   if params[:commit]=='Individual' || params[:commit]=='Bulk'
  #     redirect_to controller: 'maintainance_bill', action: 'individual_marking', params: request.request_parameters 
  #   elsif params[:commit] == 'View Details'
  #     redirect_to controller: 'maintainance_bill', action: 'particualr_project_customer', params: request.request_parameters 
  #   end
  # end
  def individual_marking
    flats = Flat.find(params[:flat_ids])
    if params[:commit]== 'Individual'
      flats.each do |flat|
        flat.update(individual_bill_generation: true)
      end
    elsif params[:commit] == 'Bulk'
      flats.each do |flat|
        flat.update(individual_bill_generation: false)
      end
    end
    
    flash[:success]='Customers marking updated successfully'
    redirect_to maintainance_bill_customer_with_flat_index_url
  end

  def particualr_project_customer
    business_unit_id=params[:business_unit][:business_unit_id]
    @flats=Flat.includes(:block).where(:blocks => {business_unit_id: business_unit_id.to_i})
  end

  def manual_maintainance_bill_send_index
    @maintainance_bills=MaintainenceBill.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: ''})
  end

  def manual_bill_send
    maintainance_bill_ids=params[:maintainance_bill_ids]    
    maintainance_bill_ids.each do |id|
      maintainance_bill=MaintainenceBill.find(id)
      maintainance_bill.update(manually_mailed_on: DateTime.now)
    end

    flash[:success]='Manual bill send updated successfully'
    redirect_to maintainance_bill_manual_maintainance_bill_send_index_url
  end

  def manual_money_receipt_send_index
    @money_receipts=MoneyReceipt.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: ''})
  end

  def manual_receipt_send
    money_receipt_ids=params[:money_receipt_ids]    
    money_receipt_ids.each do |id|
      money_receipt=MoneyReceipt.find(id)
      money_receipt.update(manually_mailed_on: DateTime.now)
    end

    flash[:success]='Manual bill send updated successfully'
    redirect_to maintainance_bill_manual_money_receipt_send_index_url
  end

  def maintenance_outstanding_feed
    total_outstanding=0
    outstanding_hash={}
    business_unit_names=['Dream Valley','Dream Palazzo','Dream Exotica','Dream Eco City']
    business_unit_names.each do |business_unit_name|
      Flat.includes(:block).where(:blocks => {business_unit_id: BusinessUnit.find_by_name(business_unit_name).id}).each do |flat|
      total_outstanding+=flat.outstanding
      end
    outstanding_hash[business_unit_name+' Maintenance']=total_outstanding
    total_outstanding=0  
    end
    render text: outstanding_hash.to_s
  end

  def flat_tag_with_lead
    if params[:business_unit]==nil
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @business_units=selections(BusinessUnit, :name)
      @flats=Flat.includes(:block => [:business_unit]).where(:business_units => {id: @business_unit_id.to_i}).where(lead_id: nil)
      @leads=Lead.includes(:flats).where(business_unit_id: @business_unit_id.to_i, status: true, lost_reason_id: nil).where(:flats => {lead_id: nil})
    end
  end

  def flat_tagging
    flat=Flat.find_by_id(params[:flat_id].to_i)
    flat.update(lead_id: params[:lead_id].to_i)

    flash[:success]='Lead tagging with flat done successfully'
    redirect_to maintainance_bill_flat_tag_with_lead_url
  end

  def credit_note_entry
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.block.name+'-'+flat.full_name, flat.id]]
      end
    end
    @customer_with_flats=@customer_with_flats.sort_by{|x,y| x}    
  end

  def credit_note
    credit_note=MaintenanceCreditNoteEntry.new
    credit_note.lead_id = Flat.find(params[:credit_note_entry][:flat_id].to_i).lead_id
    credit_note.head = params[:credit_note_entry][:head]
    credit_note.date = params[:credit_note_entry][:date]
    credit_note.amount = params[:credit_note_entry][:amount]
    credit_note.remarks = params[:credit_note_entry][:remarks]
    credit_note.remarks_to_show = params[:credit_note_entry][:remarks_to_show]
    credit_note.save

    flash[:success]='Credit Note Entry Done.'
    redirect_to report_credit_note_register_url
  end

  def credit_note_edit
    @credit_note=MaintenanceCreditNoteEntry.find(params[:format])
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.block.name+'-'+flat.full_name, flat.id]]
      end
    end
    @customer_with_flats=@customer_with_flats.sort_by{|x,y| x}    
  end

  def credit_note_update
    credit_note_entry=MaintenanceCreditNoteEntry.find(params[:credit_note_entry_id])
    credit_note_entry.update(lead_id: Flat.find(params[:credit_note_entry][:flat_id].to_i).lead_id, head: params[:credit_note_entry][:head], date: params[:credit_note_entry][:date], remarks: params[:credit_note_entry][:remarks], amount: params[:credit_note_entry][:amount], remarks_to_show: params[:credit_note_entry][:remarks_to_show])
    
    flash[:success]='Credit Note Entry Updated.'
    redirect_to report_credit_note_register_url
  end

  def credit_note_destroy
    @credit_note=MaintenanceCreditNoteEntry.find(params[:format])
    @credit_note.destroy

    flash[:success]='Credit Note Entry Deleted successfully.'
    redirect_to report_credit_note_register_url
  end

  def credit_note_preview_index
    @credit_note=MaintenanceCreditNoteEntry.find(params[:format])
  end

  def credit_note_download
    @credit_note_id=params[:credit_note_id]
    @credit_note_pdf=render_to_string(:partial => "credit_note_preview_index", :layout => false, :locals => { :credit_note_id => @credit_note_id})
    @credit_note_pdf='<html><body>'+@credit_note_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@credit_note_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'Credit Note.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        credit_note=MaintenanceCreditNoteEntry.find(@credit_note_id.to_i)
        data=[@pdf, credit_note]
        UserMailer.credit_note(data).deliver

        flash[:success]='Email send successfully.'
        redirect_to report_credit_note_register_url
    end
  end

  def credit_note_entry_in_bulk
    @blocks=[]
    BusinessUnit.where(organisation_id: current_personnel.organisation_id).each do |business_unit|
      business_unit.blocks.each do |block|
        @blocks+=[[block.business_unit.name+'-'+block.name, block.id]]
      end
    end
  end

  def credit_note_in_bulk
    block_id = params[:block_id]
    flats = Flat.where(block_id: block_id.to_i).where.not(lead_id: nil)
    rate = params[:credit_note_entry][:rate]
    flats.each do |flat|
      credit_note=MaintenanceCreditNoteEntry.new
      credit_note.lead_id = flat.lead_id
      credit_note.head = params[:credit_note_entry][:head]
      credit_note.date = params[:credit_note_entry][:date]
      amount = (rate.to_f*flat.SBA)
      credit_note.amount = amount
      credit_note.remarks = params[:credit_note_entry][:remarks]
      credit_note.remarks_to_show = params[:credit_note_entry][:remarks_to_show]
      credit_note.save
    end
    
    flash[:success]='Bulk Credit Note Generation Done.'
    redirect_to report_credit_note_register_url      
  end

  def flat_transfer
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where('flats.lead_id is not ?', nil).each do |flat|
      if flat.outstanding <= 0
        @customer_with_flats+=[[flat.block.business_unit.name+'-'+flat.block.name+'-'+flat.lead.name+'-'+flat.full_name, flat.id]]
      end
    end
  end

  def transfer_to_new_lead
    old_flat_id=params[:flat_id]
    old_flat = Flat.find(old_flat_id.to_i)
    old_lead = Lead.find(old_flat.lead.id)
    new_flat=Flat.new
    new_flat.block_id = old_flat.block_id
    new_flat.name = old_flat.name
    new_flat.floor = old_flat.floor
    new_flat.BHK = old_flat.BHK
    new_flat.SBA = old_flat.SBA
    new_flat.save

    mobile = params[:lead][:mobile]    
    lead = Lead.find_by_mobile(mobile)
    if lead == nil
      new_lead = Lead.new
      new_lead.name = params[:lead][:name]
      new_lead.email = params[:lead][:email]
      new_lead.mobile = params[:lead][:mobile]
      new_lead.business_unit_id = new_flat.block.business_unit_id
      new_lead.save
      old_flat.update(individual_bill_generation: true, remarks: new_lead.name+'-'+'Transfer Date:'+params[:transfer_date].to_date.strftime('%d/%m/%Y'))
      new_flat.update(individual_bill_generation: true, lead_id: new_lead.id, remarks: old_lead.name+'-'+'Transfer Date:'+params[:transfer_date].to_date.strftime('%d/%m/%Y'))
    else
      lead.update(name: params[:lead][:name], email: params[:lead][:email], mobile: params[:lead][:mobile])
      old_flat.update(individual_bill_generation: true, remarks: lead.name+'-'+'Transfer Date:'+params[:transfer_date].to_date.strftime('%d/%m/%Y'))
      new_flat.update(individual_bill_generation: true, lead_id: lead.id, remarks: old_lead.name+'-'+'Transfer Date:'+params[:transfer_date].to_date.strftime('%d/%m/%Y'))
    end

    flash[:success]='Flat Transfer Done successfully.'    
    redirect_to maintainance_bill_flat_transfer_url
  end

# ----------------------------------------------------------------------------------------------------------------------

  private
    
    def maintainance_bill_params
    	params.require(:maintainence_bill).permit(:from, :to, :date, :rate)
    end

    def individual_maintainance_bill_params
      params.require(:maintainence_bill).permit(:from, :to, :date, :rate)
    end

    def money_receipt_params
      params.require(:money_receipt).permit(:flat_id, :amount, :date, :cheque_number, :bank_name, :remarks, :period)
    end
end

