class MaintainanceLedgerController < ApplicationController
  def maintainance_ledger_index
  	@maintainance_ledger_entries=MaintainenceLedgerEntry.all
  end
  def maintainance_ledger_new
  	@maintainance_ledger=MaintainenceLedgerEntry.new
    #@companies=selectoptions(Company, :name)
    #@business_units=selectoptions(BusinessUnit, :name)
    @maintainance_ledger_action='maintainance_ledger_create'
  end
  def maintainance_ledger_create
  	@maintainance_ledger=MaintainenceLedgerEntry.new(maintainance_ledger_params)
  	@maintainance_ledger.save

  	redirect_to maintainance_ledger_maintainance_ledger_index_url
  end


  def maintainance_ledger_edit
  	@maintainance_ledger= MaintainenceLedgerEntry.find(params[:format])
    # @companies=selectoptions(Company, :name)
    # @business_units=selectoptions(BusinessUnit, :name)
  	@maintainance_ledger_action='maintainance_ledger_updated'
  end


  def maintainance_ledger_update
  	@maintainance_ledger=MaintainenceLedgerEntry.find(params[:maintainance_ledger_id])
    @maintainance_ledger.update(maintainance_ledger_params)

  	redirect_to maintainance_ledger_maintainance_ledger_index_url
  end
  def maintainance_ledger_destroy
  	@maintainance_ledger_entry=MaintainenceLedgerEntry.find(params[:format])
  	@maintainance_ledger_entry.destroy
  	redirect_to maintainance_ledger_maintainance_ledger_index_url
  end

################################################################################################
  private

  def maintainance_ledger_params
    params.require(:maintainence_ledger_entry).permit(:lead_id, :date, :amount, :maintainence_bill_id, :money_receipt_id)
  end
end 
