class CreditNoteHeadController < ApplicationController
	def credit_note_head_index
		@credit_note_heads=CreditNoteHead.includes(:organisation).where(organisation_id: current_personnel.organisation_id)
	end

	def credit_note_head_new
		@credit_note_head=CreditNoteHead.new
		@credit_note_head_action = 'credit_note_head_create'
	end

	def credit_note_head_create
		credit_note_head=CreditNoteHead.new(credit_note_head_params)
		credit_note_head.organisation_id = current_personnel.organisation_id
		credit_note_head.save

		flash[:success]='Credit Note Head Generated successfully.'
		redirect_to credit_note_head_credit_note_head_index_url
	end

	def credit_note_head_edit
		@credit_note_head=CreditNoteHead.find(params[:format])
		@credit_note_head_action = 'credit_note_head_update'
	end

	def credit_note_head_update
		@credit_note_head=CreditNoteHead.find(params[:credit_note_head_id])
		@credit_note_head.update(credit_note_head_params)

		flash[:success]='Credit Note Head Updated successfully.'
		redirect_to credit_note_head_credit_note_head_index_url
	end

	def credit_note_head_destroy
		@credit_note_head=CreditNoteHead.find(params[:format])
		@credit_note_head.destroy

		flash[:success]='Credit Note Head Destroyed successfully.'
		redirect_to credit_note_head_credit_note_head_index_url
	end

	def credit_note_register
		@credit_note_entries=CreditNoteEntry.includes(:booking, :credit_note_head).where(:credit_note_heads => {organisation_id: current_personnel.organisation_id})
	end
	

	private
		def credit_note_head_params
			params.require(:credit_note_head).permit(:description)
		end
end
