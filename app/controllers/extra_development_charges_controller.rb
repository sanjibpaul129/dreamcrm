class ExtraDevelopmentChargesController < ApplicationController

	def extra_development_charges_index
    @extra_development_charges = ExtraDevelopmentCharge.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
  	end

  	def extra_development_charges_new
  	#@organisations=select_options(Organisation, :name)
    @extra_development_charge=ExtraDevelopmentCharge.new
    @business_units=selections(BusinessUnit,:name)
    @extra_charges=selections(ExtraCharge,:description)
    @blocks=[['All', -1]]
		Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
			@blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
		end
    @extra_development_charges_action='extra_development_charges_create'
  	end
  	def extra_development_charges_create
    @extra_development_charge = ExtraDevelopmentCharge.new(extra_development_charge_params)
    @extra_development_charge.save
    flash[:info]='extra_development_charge was successfully created.'
    redirect_to extra_development_charges_extra_development_charges_index_url
 	end
  	def extra_development_charges_edit
  	#@orgnaisations=select_options(Organisation, :name)
  	@business_units=selections(BusinessUnit,:name)
    @extra_charges=selections(ExtraCharge,:description)
    @blocks=[['All', -1]]
		Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
			@blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
		end
    @extra_development_charge=ExtraDevelopmentCharge.find(params[:format])
    @extra_development_charges_action='extra_development_charges_update'  
  	end

  	def extra_development_charges_update
    @extra_development_charge=ExtraDevelopmentCharge.find(params[:extra_development_charge_id])
    @extra_development_charge.update(extra_development_charge_params)
    flash[:info]='extra_development_charge was successfully updated.'
    redirect_to extra_development_charges_extra_development_charges_index_url
  	end

  	def extra_development_charges_destroy
    @extra_development_charge=ExtraDevelopmentCharge.find(params[:format])
    @extra_development_charge.destroy
    flash[:info]='extra_development_charge was successfully destroyed.'
    redirect_to extra_development_charges_extra_development_charges_index_url
  	end	
	
	private
	  def extra_development_charge_params
	    params.require(:extra_development_charge).permit(:business_unit_id,:extra_charge_id,:block_id,:percentage,:amount,:rate,:flat_type)
	  end
end
