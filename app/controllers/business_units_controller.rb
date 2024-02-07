class BusinessUnitsController < ApplicationController
  before_action :set_business_unit, only: [:show, :edit, :update, :destroy]

  # GET /business_units
  # GET /business_units.json
  def index
    if current_personnel.email=='ayush@thejaingroup.com'
    @business_units = BusinessUnit.all
    else  
    @business_units = BusinessUnit.where(organisation_id: current_personnel.organisation_id)
    end
  end

  # GET /business_units/1
  # GET /business_units/1.json
  def show
  end

  # GET /business_units/new
  def new
    @business_unit = BusinessUnit.new
    @organisations=selectoptions(Organisation, :name)
    @companies=selectoptions(Company, :name)
  end

  # GET /business_units/1/edit
  def edit
    @organisations=selectoptions(Organisation, :name)
    @companies=selectoptions(Company, :name)
  end

  # POST /business_units
  # POST /business_units.json
  def create
    @business_unit = BusinessUnit.new(business_unit_params)

    if params[:business_unit][:auto_allocate]==nil
      @business_unit.auto_allocate=nil
    end

    respond_to do |format|
      if @business_unit.save
        format.html { redirect_to business_units_url, notice: 'Business unit was successfully created.' }
        format.json { render action: 'show', status: :created, location: @business_unit }
      else
        format.html { render action: 'new' }
        format.json { render json: @business_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /business_units/1
  # PATCH/PUT /business_units/1.json
  def update
    respond_to do |format|
      if @business_unit.update(business_unit_params)
        if params[:business_unit][:auto_allocate]==nil
          @business_unit.update(auto_allocate: nil)
        end
        format.html { redirect_to business_units_url, notice: 'Business unit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @business_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /business_units/1
  # DELETE /business_units/1.json
  def destroy
    @business_unit.destroy
    respond_to do |format|
      format.html { redirect_to business_units_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business_unit
      @business_unit = BusinessUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_unit_params
      params.require(:business_unit).permit(:name, :organisation_id, :company_id, :address_1, :address_2, :address_3, :address_4, :email, :shortform, :logo, :open_covered_ratio, :base_rate, :walkthrough, :auto_allocate, :hira_registration_number, :bank_name, :branch_address, :account_number, :ifsc_code, :locality, :area, :city, :pincode)
    end
end
