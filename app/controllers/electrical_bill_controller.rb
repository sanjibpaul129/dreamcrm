class ElectricalBillController < ApplicationController

  def electrical_bill_index
  	@electrical_bills=ElectricalBill.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: ''})
  end
  
  def electrical_bill_new
  	@electrical_bill=ElectricalBill.new
    @business_units=selections(BusinessUnit, :name)
    @electrical_bill_action='electrical_bill_create'
  end

  def electrical_bill_create
  	flat = Flat.where(id: params[:flat_id].to_i)[0]
  	from=params[:electrical_bill][:from]    
    to=params[:electrical_bill][:to]
    duplicate_flats=[]
    duplicate=[]
    # from_duplicate=ElectricalBill.where(flat_id: flat.id).where('"from" <= ? and "to" >= ?', from, from)
    # to_duplicate=ElectricalBill.where(flat_id: flat.id).where('"from" <= ? and "to" >= ?', to, to)
    # duplicate = from_duplicate+to_duplicate
    if duplicate != []
      duplicate_flats =[flat.name]
    else
      @electrical_bill=ElectricalBill.new(electrical_bill_params)
      @electrical_bill.flat_id = flat.id
      @electrical_bill.lead_id = flat.lead_id
      if params[:electrical_bill][:unit] == nil || params[:electrical_bill][:unit] == ''
        @electrical_bill.unit = params[:electrical_bill][:closing_reading].to_i-params[:electrical_bill][:opening_reading].to_i
      else
        @electrical_bill.unit=params[:electrical_bill][:unit]
      end
      if ElectricalBillSerial.all.count == 0
      	electrical_bill_serial=ElectricalBillSerial.new
      	electrical_bill_serial.last = 1
      	electrical_bill_serial.save
      	@electrical_bill.serial=electrical_bill_serial.last
      else
	    electrical_bill_serial=ElectricalBillSerial.find(1)
	    electrical_bill_serial.update(last: electrical_bill_serial.last+1)
	    @electrical_bill.serial=electrical_bill_serial.last
  	  end
      @electrical_bill.save  
      @electrical_bill.update(amount: ((@electrical_bill.unit * @electrical_bill.rate)*1.18).round)
    end
    if duplicate_flats != []
      flash[:danger]='bill is duplicate for this customer'
    else
      flash[:success]='Bill Generated successfully.'
    end
    redirect_to electrical_bill_electrical_bill_index_url
  end
  
  def electrical_bill_edit
  	@electrical_bill=ElectricalBill.find(params[:format])
    @electrical_bill_action='electrical_bill_update'
  end
  
  def electrical_bill_update
  	@electrical_bill= ElectricalBill.find(params[:electrical_bill_id])
  	@electrical_bill.update(electrical_bill_params)
    @electrical_bill.update(amount: ((@electrical_bill.unit * @electrical_bill.rate)*1.18).round)
    
    flash[:success]='Bill updated successfully.'
  	redirect_to electrical_bill_electrical_bill_index_url
  end
  
  def electrical_bill_destroy
  	@electrical_bill=ElectricalBill.find(params[:format])
  	@electrical_bill.destroy

    flash[:success]='Bill destroyed successfully.'
  	redirect_to electrical_bill_electrical_bill_index_url
  end

  def populate_electric_rate
      @business_unit_id=params[:id]
      @rate= ElectricalCharge.find_by_business_unit_id(@business_unit_id).rate
      respond_to do |format|
          format.js { render :action => "populate_electric_rate"}
      end
  end

  def electrical_bill_preview_index
    @electrical_bill=ElectricalBill.find(params[:format])
  end

  def electrical_bill_download
    @electrical_bill_id=params[:electrical_bill_id]
    @electrical_bill_pdf=render_to_string(:partial => "electrical_bill_preview_index", :layout => false, :locals => { :electrical_bill_id => @electrical_bill_id})
    @electrical_bill_pdf='<html><body>'+@electrical_bill_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@electrical_bill_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'ElectricBill.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        electrical_bill=ElectricalBill.find(@electrical_bill_id.to_i)
        data=[@pdf, electrical_bill]
        UserMailer.electrical_bill(data).deliver

        electrical_bill = ElectricalBill.find(params[:electrical_bill_id])
        electrical_bill.update(mailed_on: DateTime.now)

        flash[:success]='Email send successfully.'
        redirect_to electrical_bill_electrical_bill_index_url
    end
  end

  def electrical_bill_pdf_converter
	electrical_bill_ids=params[:electrical_bill_ids]
    electrical_bill_ids.each do |electrical_bill_id|
      electrical_bill=ElectricalBill.find(electrical_bill_id)
      @electrical_bill_pdf=render_to_string(:partial => "electrical_bill_preview_index", :layout => false, :locals => { :electrical_bill_id => electrical_bill.id})
      @electrical_bill_pdf='<html><body>'+@electrical_bill_pdf+'</body></html>'
      @pdf = WickedPdf.new.pdf_from_string(@electrical_bill_pdf)
      data=[@pdf, electrical_bill]
      if Lead.find(electrical_bill.lead_id).email==nil || Lead.find(electrical_bill.lead_id).email==''
      else
      UserMailer.electrical_bill(data).deliver      
      electrical_bill.update(mailed_on: DateTime.now)
      end
    end

	  flash[:success]='Email send successfully.'
	  redirect_to electrical_bill_electrical_bill_index_url
  end

  def manual_electrical_bill_send_index
    @electrical_bills=ElectricalBill.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: ''})
  end

  def manual_electrical_bill_send
    electrical_bill_ids=params[:electrical_bill_ids]    
    electrical_bill_ids.each do |id|
      electrical_bill=ElectricalBill.find(id)
      electrical_bill.update(manually_mailed_on: DateTime.now)
    end

    flash[:success]='Manual bill sent successfully'
    redirect_to electrical_bill_manual_electrical_bill_send_index_url
  end
# ----------------------------------------------------------------------------------------------------------------------

  def electrical_money_receipt_index
    @electrical_money_receipts=ElectricalMoneyReceipt.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where.not(:leads => {email: ''})
  end

  def electrical_money_receipt_new
    @electrical_money_receipt=ElectricalMoneyReceipt.new
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.full_name, flat.id]]
      end
    end
    @customer_with_flats=@customer_with_flats.sort_by{|x,y| x}
    @electrical_money_receipt_action='electrical_money_receipt_create'
  end

  def electrical_money_receipt_create
    @money_receipts=ElectricalMoneyReceipt.new(electrical_money_receipt_params)  
    lead=Flat.where(id: params[:electrical_money_receipt][:flat_id])[0]
    @money_receipts.lead_id=lead.lead_id
    @money_receipts.save
    
    flash[:success]='Money Receipt Generated successfully.'
    redirect_to electrical_bill_electrical_money_receipt_index_url    
  end

  def electrical_money_receipt_edit
    @electrical_money_receipt=ElectricalMoneyReceipt.find(params[:format])
    @customer_with_flats=[]
    Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |flat|
      if flat.lead_id != nil
        @customer_with_flats+=[[flat.lead.name+'-'+flat.full_name, flat.id]]
      end
    end
    @electrical_money_receipt_action='electrical_money_receipt_update'
  end

  def electrical_money_receipt_update
    @electrical_money_receipt= ElectricalMoneyReceipt.find(params[:electrical_money_receipt_id])
    lead=Flat.where(id: params[:electrical_money_receipt][:flat_id])[0]
    @electrical_money_receipt.lead_id=lead.lead_id
    @electrical_money_receipt.update(electrical_money_receipt_params)

    flash[:success]='Money Receipt updated successfully.'
    redirect_to electrical_bill_electrical_money_receipt_index_url    
  end

  def electrical_money_receipt_destroy
    @electrical_money_receipt=ElectricalMoneyReceipt.find(params[:format])
    @electrical_money_receipt.destroy

    flash[:success]='Money Receipt destroyed successfully.'
    redirect_to electrical_bill_electrical_money_receipt_index_url    
  end

  def electrical_money_receipt_preview_index
    @electrical_money_receipt=ElectricalMoneyReceipt.find(params[:format])
  end

  def electrical_money_receipt_pdf_converter
    electrical_money_receipt_ids=params[:electrical_money_receipt_ids]
    electrical_money_receipt_ids.each do |electrical_money_receipt|
      electrical_money_receipt=ElectricalMoneyReceipt.find(electrical_money_receipt)
      @electrical_money_receipt_pdf=render_to_string(:partial => "electrical_money_receipt_preview_index", :layout => false, :locals => { :electrical_money_receipt_id => electrical_money_receipt.id})
      @electrical_money_receipt_pdf='<html><body>'+@electrical_money_receipt_pdf+'</body></html>'
      @pdf = WickedPdf.new.pdf_from_string(@electrical_money_receipt_pdf)
      data=[@pdf, electrical_money_receipt]
      UserMailer.electrical_money_receipt(data).deliver      
      electrical_money_receipt.update(mailed_on: DateTime.now)
    end

    flash[:success]='Email send successfully.'
    redirect_to electrical_bill_electrical_money_receipt_index_url
  end

def electrical_money_receipt_download
    @electrical_money_receipt_id=params[:electrical_money_receipt_id]
    @electrical_money_receipt_pdf=render_to_string(:partial => "electrical_money_receipt_preview_index", :layout => false, :locals => { :electrical_money_receipt_id => @electrical_money_receipt_id})
    @electrical_money_receipt_pdf='<html><body>'+@electrical_money_receipt_pdf+'</body></html>'
    @pdf = WickedPdf.new.pdf_from_string(@electrical_money_receipt_pdf)
    if params[:download]=='Download'
        send_data(@pdf, filename: 'Money Receipt.pdf', type: 'application/pdf')
    elsif params[:email]=='Email'
        data=[@pdf]
        UserMailer.electrical_money_receipt(data).deliver

        electrical_money_receipt = ElectricalMoneyReceipt.find(params[:electrical_money_receipt_id])
        electrical_money_receipt.update(mailed_on: DateTime.now)
        
        flash[:success]='Email send successfully.'
        redirect_to electrical_bill_electrical_money_receipt_index_url
    end
end

def manual_electrical_receipt_send_index
    @electrical_money_receipts=ElectricalMoneyReceipt.includes(:lead => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).where(mailed_on: nil, manually_mailed_on: nil).where(:leads => {email: ''})
end

def manual_electrical_receipt_send
    electrical_money_receipt_ids=params[:electrical_money_receipt_ids]    
    electrical_money_receipt_ids.each do |id|
      electrical_money_receipt=ElectricalMoneyReceipt.find(id)
      electrical_money_receipt.update(manually_mailed_on: DateTime.now)
    end

    flash[:success]='Manual bill send updated successfully'
    redirect_to electrical_bill_manual_electrical_receipt_send_index_url
end

# ----------------------------------------------------------------------------------------------------------------------

  private
    
    def electrical_bill_params
    	params.require(:electrical_bill).permit(:from, :to, :date, :rate, :opening_reading, :closing_reading)
    end

    def electrical_money_receipt_params
      params.require(:electrical_money_receipt).permit(:flat_id, :amount, :date, :cheque_number, :bank_name, :remarks, :opening_reading, :closing_reading)
    end
end
