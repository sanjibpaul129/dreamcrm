class FlcChargesController < ApplicationController
  before_action :set_flc_charge, only: [:show, :edit, :update, :destroy]

  # GET /flc_charges
  # GET /flc_charges.json
  def index
    @flc_charges = FlcCharge.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  # GET /flc_charges/1
  # GET /flc_charges/1.json
  def show
  end

  # GET /flc_charges/new
  def new
    @blocks=[]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
    @flc_charge = FlcCharge.new
  end

  # GET /flc_charges/1/edit
  def edit
    @blocks=[]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
  end

  # POST /flc_charges
  # POST /flc_charges.json
  def create
    @flc_charge = FlcCharge.new(flc_charge_params)

    respond_to do |format|
      if @flc_charge.save
        format.html { redirect_to @flc_charge, notice: 'Flc charge was successfully created.' }
        format.json { render action: 'show', status: :created, location: @flc_charge }
      else
        format.html { render action: 'new' }
        format.json { render json: @flc_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flc_charges/1
  # PATCH/PUT /flc_charges/1.json
  def update
    respond_to do |format|
      if @flc_charge.update(flc_charge_params)
        format.html { redirect_to @flc_charge, notice: 'Flc charge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @flc_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flc_charges/1
  # DELETE /flc_charges/1.json
  def destroy
    @flc_charge.destroy
    respond_to do |format|
      format.html { redirect_to flc_charges_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flc_charge
      @flc_charge = FlcCharge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flc_charge_params
      params.require(:flc_charge).permit(:block_id, :rate, :from_floor)
    end
end
