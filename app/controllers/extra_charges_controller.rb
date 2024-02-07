class ExtraChargesController < ApplicationController
  before_action :set_extra_charge, only: [:show, :edit, :update, :destroy]

  # GET /extra_charges
  # GET /extra_charges.json
  def index
    @extra_charges = ExtraCharge.where(organisation_id: current_personnel.organisation_id)
  end

  # GET /extra_charges/1
  # GET /extra_charges/1.json
  def show
  end

  # GET /extra_charges/new
  def new
    @extra_charge = ExtraCharge.new
  end

  # GET /extra_charges/1/edit
  def edit
  end

  # POST /extra_charges
  # POST /extra_charges.json
  def create
    @extra_charge = ExtraCharge.new(extra_charge_params)
    @extra_charge.organisation_id=current_personnel.organisation_id

    respond_to do |format|
      if @extra_charge.save
        format.html { redirect_to @extra_charge, notice: 'Extra charge was successfully created.' }
        format.json { render action: 'show', status: :created, location: @extra_charge }
      else
        format.html { render action: 'new' }
        format.json { render json: @extra_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extra_charges/1
  # PATCH/PUT /extra_charges/1.json
  def update
    respond_to do |format|
      if @extra_charge.update(extra_charge_params)
        format.html { redirect_to @extra_charge, notice: 'Extra charge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @extra_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /extra_charges/1
  # DELETE /extra_charges/1.json
  def destroy
    @extra_charge.destroy
    respond_to do |format|
      format.html { redirect_to extra_charges_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extra_charge
      @extra_charge = ExtraCharge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extra_charge_params
      params.require(:extra_charge).permit(:organisation_id, :description, :service_tax)
    end
end
