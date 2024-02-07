class TaxController < ApplicationController
	def index
    @taxs=Tax.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
	end

	def show
	end

	  
	def new
	@tax=Tax.new
    @business_units=selections(BusinessUnit,:name)
    @tax_action='create'    
	end

	def edit
	@business_units=selections(BusinessUnit,:name)
    @tax=Tax.find(params[:format])
    @tax_action='update'  
	end

	def create
	@tax = Tax.new(tax_params)
    @tax.save
    flash[:info]='tax was successfully created.'
    redirect_to :controller => 'tax', :action => 'index'
	end

	 
	def update
	@tax=Tax.find(params[:tax_id])
    @tax.update(tax_params)
    flash[:info]='tax was successfully updated.'
    redirect_to :controller => 'tax', :action => 'index'
	end

	  
	def destroy
	@tax=Tax.find(params[:format])
    @tax.destroy
    flash[:info]='tax was successfully destroyed.'
    redirect_to :controller => 'tax', :action => 'index'
	end

	private
	  def tax_params
	    params.require(:tax).permit(:business_unit_id,:name,:overall,:car_park,:basic,:plc,:edc,:servant_quarter,:applicable_from)
	  end
end
