class PlcChargesController < ApplicationController
  before_action :set_plc_charge, only: [:show, :edit, :update, :destroy]

  # GET /plc_charges
  # GET /plc_charges.json
  def index
    @plc_charges = PlcCharge.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  # GET /plc_charges/1
  # GET /plc_charges/1.json
  def show
  end

  # GET /plc_charges/new
  def new
    @plc_charge = PlcCharge.new
    @blocks=[]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
    @plcs=[]
    Plc.where(organisation_id: current_personnel.organisation_id).each do |plc|
      @plcs+=[[plc.name,plc.id]]
    end
    @flat_names=Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).pluck("flats.name").uniq
  end

  # GET /plc_charges/1/edit
  def edit
    @blocks=[]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
    @plcs=[]
    Plc.where(organisation_id: current_personnel.organisation_id).each do |plc|
      @plcs+=[[plc.name,plc.id]]
    end
    @flat_names=Flat.includes(:block => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}).pluck("flats.name").uniq
  end

  # POST /plc_charges
  # POST /plc_charges.json
  def create
    @plc_charge = PlcCharge.new(plc_charge_params)
    respond_to do |format|
      if @plc_charge.save
        format.html { redirect_to @plc_charge, notice: 'Plc charge was successfully created.' }
        format.json { render action: 'show', status: :created, location: @plc_charge }
      else
        format.html { render action: 'new' }
        format.json { render json: @plc_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plc_charges/1
  # PATCH/PUT /plc_charges/1.json
  def update
    respond_to do |format|
      if @plc_charge.update(plc_charge_params)
        format.html { redirect_to @plc_charge, notice: 'Plc charge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @plc_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plc_charges/1
  # DELETE /plc_charges/1.json
  def destroy
    @plc_charge.destroy
    respond_to do |format|
      format.html { redirect_to plc_charges_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plc_charge
      @plc_charge = PlcCharge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plc_charge_params
      params.require(:plc_charge).permit(:block_id, :plc_id, :rate, :floor ,:flat_name)
    end
end
