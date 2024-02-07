class ElectricalController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:electrical_outstanding_feed]

  def electrical_index
  	@electrical_charges=ElectricalCharge.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  def electrical_new
  	@electrical=ElectricalCharge.new
  	@companies=selectoptions(Company, :name)
  	@business_units=selectoptions(BusinessUnit, :name)
  	@electrical_action='electrical_create'
  end

  def electrical_create
  	@electrical_charges=ElectricalCharge.new(electrical_params)
  	@electrical_charges.save

    flash[:success]='Charges Generated successfully.'
  	redirect_to electrical_electrical_index_url
  end

  def electrical_edit
  	@electrical=ElectricalCharge.find(params[:format])
    @companies=selectoptions(Company, :name)
    @business_units=selectoptions(BusinessUnit, :name)
  	@electrical_action='electrical_update'
  end

  def electrical_update
  	@electrical_charge=ElectricalCharge.find(params[:electrical_id])
  	@electrical_charge.update(electrical_params)
    
    flash[:success]='Charges updated successfully.'
    redirect_to electrical_electrical_index_url
  end

  def electrical_destroy
  	@electrical_charge=ElectricalCharge.find(params[:format])
  	@electrical_charge.destroy

    flash[:success]='Charges destroyed successfully.'
  	redirect_to electrical_electrical_index_url
  end

  def electrical_outstanding_feed
    total_outstanding=0
    outstanding_hash={}
    business_unit_names=['Dream Valley','Dream Palazzo','Dream Exotica','Dream Eco City']
    business_unit_names.each do |business_unit_name|
      Flat.includes(:block).where(:blocks => {business_unit_id: BusinessUnit.find_by_name(business_unit_name).id}).each do |flat|
      total_outstanding+=flat.electrical_outstanding
      end
    outstanding_hash[business_unit_name+' Electrical']=total_outstanding
    total_outstanding=0  
    end
    render text: outstanding_hash.to_s
  end
  # -------------------------------------------------------------------------------------------------------------------
  private

  def electrical_params
  	params.require(:electrical_charge).permit(:rate, :applicable_from, :business_unit_id, :company_id)
  end

end
