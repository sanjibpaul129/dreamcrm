class AdhocChargeController < ApplicationController
	def adhoc_charge_index
		@adhoc_charges=AdhocCharge.includes(:organisation).where(organisation_id: current_personnel.organisation_id)
	end

	def adhoc_charge_new
		@adhoc_charge=AdhocCharge.new
		@adhoc_charge_action = 'adhoc_charge_create'
	end

	def adhoc_charge_create
		adhoc_charge=AdhocCharge.new(adhoc_charge_params)
		adhoc_charge.organisation_id = current_personnel.organisation_id
		adhoc_charge.save

		flash[:success]='Adhoc Charge Generated successfully.'
		redirect_to adhoc_charge_adhoc_charge_index_url
	end

	def adhoc_charge_edit
		@adhoc_charge=AdhocCharge.find(params[:format])
		@adhoc_charge_action = 'adhoc_charge_update'
	end

	def adhoc_charge_update
		@adhoc_charge=AdhocCharge.find(params[:adhoc_charge_id])
		@adhoc_charge.update(adhoc_charge_params)

		flash[:success]='Adhoc Charge Updated successfully.'
		redirect_to adhoc_charge_adhoc_charge_index_url
	end

	def adhoc_charge_destroy
		@adhoc_charge=AdhocCharge.find(params[:format])
		@adhoc_charge.destroy

		flash[:success]='Adhoc Charge Destroyed successfully.'
		redirect_to adhoc_charge_adhoc_charge_index_url
	end

	def adhoc_charge_register
		@adhoc_charge_entries=AdhocChargeEntry.includes(:booking, :adhoc_charge).where(:adhoc_charges => {organisation_id: current_personnel.organisation_id})
	end

	private
		def adhoc_charge_params
			params.require(:adhoc_charge).permit(:description)
		end
end
