class ServantQuarterController < ApplicationController
	def index
    @servant_quarters=ServantQuarter.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
	end

	def show
	end

	  
	def new
	@servant_quarter=ServantQuarter.new
    @business_units=selections(BusinessUnit,:name)
    @servant_quarters_action='create'    
	end

	def edit
	@business_units=selections(BusinessUnit,:name)
    @servant_quarter=ServantQuarter.find(params[:format])
    @servant_quarters_action='update'  
	end

	def create
	@servant_quarter = ServantQuarter.new(servant_quarter_params)
    @servant_quarter.save
    flash[:info]='servant_quarter was successfully created.'
    redirect_to :controller => 'servant_quarter', :action => 'index'
	end

	 
	def update
	@servant_quarter=ServantQuarter.find(params[:servant_quarter_id])
    @servant_quarter.update(servant_quarter_params)
    flash[:info]='servant_quarter was successfully updated.'
    redirect_to :controller => 'servant_quarter', :action => 'index'
	end

	  
	def destroy
	@servant_quarter=ServantQuarter.find(params[:format])
    @servant_quarter.destroy
    flash[:info]='servant_quarter was successfully destroyed.'
    redirect_to :controller => 'servant_quarter', :action => 'index'
	end

	private
	  def servant_quarter_params
	    params.require(:servant_quarter).permit(:business_unit_id,:rate,:date)
	  end
end
