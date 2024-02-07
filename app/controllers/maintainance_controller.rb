class MaintainanceController < ApplicationController
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
      money_receipts=MoneyReceipt.includes(:flat => [:block]).where(:blocks => {business_unit_id: business_unit.id}).where('money_receipts.date >= ? and money_receipts.date <= ?', from, to)       
        money_receipts.each do |money_receipt|
          total+=money_receipt.amount
        end
      collection+=[total.round]  
      end
    end
    render text: collection.to_s 
  end 

  def maintainance_index
  	@maintainance_charges=MaintainenceCharge.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  def maintainance_new
  	@maintainance=MaintainenceCharge.new
  	@companies=selectoptions(Company, :name)
  	@business_units=selectoptions(BusinessUnit, :name)
  	@maintainance_action='maintainance_create'
  end

  def maintainance_create
  	@maintainance_charges=MaintainenceCharge.new(maintainance_params)
  	@maintainance_charges.company_id=params[:maintainence_charge][:company_id]
    @maintainance_charges.business_unit_id=params[:maintainence_charge][:business_unit_id]
  	@maintainance_charges.save

  	redirect_to maintainance_maintainance_index_url
  end

  def maintainance_edit
  	@maintainance=MaintainenceCharge.find(params[:format])
    @companies=selectoptions(Company, :name)
    @business_units=selectoptions(BusinessUnit, :name)
  	@maintainance_action='maintainance_update'
  end

  def maintainance_update
  	@maintainance_charge=MaintainenceCharge.find(params[:maintainance_id])
  	@maintainance_charge.update(maintainance_params)
    @maintainance_charge.update(business_unit_id: params[:maintainence_charge][:business_unit_id], company_id: params[:maintainence_charge][:company_id])
  	redirect_to maintainance_maintainance_index_url
  end

  def sample_testing
    @from=(Date.today)-30
    @to=(Date.today)
    @sources=SourceCategory.where(organisation_id: current_personnel.organisation_id)
    @leads_generated_raw=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}).where('leads.generated_on >= ? AND leads.generated_on < ?',@from, @to.to_date+1.day)
    @leads_generated=@leads_generated_raw.group("leads.source_category_id").count
    @site_visited=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}).where.not(site_visited_on: nil).where('leads.site_visited_on >= ? AND leads.site_visited_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
    @booked=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, lost_reason_id: nil, status: true).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
    @leads_lost=Lead.includes(:personnel).where(:personnels => {organisation_id: current_personnel.organisation_id}, status: true).where.not(lost_reason_id: nil).where('leads.booked_on >= ? AND leads.booked_on < ?',@from, @to.to_date+1.day).group("leads.source_category_id").count
    @site_visited_from_leads_generated=@leads_generated_raw.where.not(site_visited_on: nil).group("leads.source_category_id").count
    @booked_from_leads_generated=@leads_generated_raw.where(lost_reason_id: nil, status: true).group("leads.source_category_id").count
    @lost_from_leads_generated=@leads_generated_raw.where(status: true).where.not(lost_reason_id: nil).group("leads.source_category_id").count

    all_sources=@leads_generated.merge(@site_visited).merge(@booked).merge(@leads_lost)
    all_sources=all_sources.keys.uniq
    
    @source_tree={}
    successors=[]
    successor_chain=0
    all_sources.each do |source|
      if @leads_generated[source]==nil
        leads_generated=0
      else
        leads_generated=@leads_generated[source]
      end
      if @site_visited[source]==nil
        site_visited=0
      else
        site_visited=@site_visited[source]
      end
      if @booked[source]==nil
        booked=0
      else
        booked=@booked[source]
      end
      if @leads_lost[source]==nil
        leads_lost=0
      else
        leads_lost=@leads_lost[source]
      end
      if @site_visited_from_leads_generated[source]==nil
        site_visited_from_leads_generated=0
      else
        site_visited_from_leads_generated=@site_visited_from_leads_generated[source]
      end
      if @booked_from_leads_generated[source]==nil
        booked_from_leads_generated=0
      else
        booked_from_leads_generated=@booked_from_leads_generated[source]
      end
      if @lost_from_leads_generated[source]==nil
        lost_from_leads_generated=0
      else
        lost_from_leads_generated=@lost_from_leads_generated[source]
      end

      predecessor_id=@sources.find(source).predecessor
      successors=[]
      if predecessor_id==nil
        @source_tree[source]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated]
      else
        successors+=[source]
        until predecessor_id==nil do
          predecessor=@sources.find(predecessor_id) 
          successors+=[predecessor_id]
          predecessor_id=predecessor.predecessor
        end
        successors=successors.reverse
        successor_chain=nil
        @source=source
        successors.each do |successor|
          if successor==successors.first
            if @source_tree[successor]==nil
              @source_tree[successor]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated]  
            else
              @source_tree[successor][0]=@source_tree[successor][0]+leads_generated
              @source_tree[successor][3]=@source_tree[successor][3]+site_visited
              @source_tree[successor][5]=@source_tree[successor][5]+booked
              @source_tree[successor][7]=@source_tree[successor][7]+leads_lost
              @source_tree[successor][9]=@source_tree[successor][9]+site_visited_from_leads_generated
              @source_tree[successor][11]=@source_tree[successor][11]+booked_from_leads_generated
              @source_tree[successor][13]=@source_tree[successor][13]+lost_from_leads_generated
            end
          successor_chain=@source_tree[successor][2]
          else
            if successor_chain[successor]==nil
              successor_chain[successor]=[leads_generated,leads_generated,{},site_visited,site_visited,booked,booked,leads_lost,leads_lost,site_visited_from_leads_generated,site_visited_from_leads_generated,booked_from_leads_generated,booked_from_leads_generated,lost_from_leads_generated,lost_from_leads_generated]
            else
              successor_chain[successor][0]=successor_chain[successor][0]+leads_generated
              successor_chain[successor][3]=successor_chain[successor][3]+site_visited
              successor_chain[successor][5]=successor_chain[successor][5]+booked
              successor_chain[successor][7]=successor_chain[successor][7]+leads_lost
              successor_chain[successor][9]=successor_chain[successor][9]+site_visited_from_leads_generated
              successor_chain[successor][11]=successor_chain[successor][11]+booked_from_leads_generated
              successor_chain[successor][13]=successor_chain[successor][13]+lost_from_leads_generated  
            end
          successor_chain=successor_chain[successor][2]
          end
        end  
      end
    end
  end

  def maintainance_destroy
  	@maintainance_charge=MaintainenceCharge.find(params[:format])
  	@maintainance_charge.destroy

  	redirect_to maintainance_maintainance_index_url
  end

  # -------------------------------------------------------------------------------------------------------------------
  private

  def maintainance_params
  	params.require(:maintainence_charge).permit(:rate, :applicable_from, :business_unit_id, :company_id)
  end
end
