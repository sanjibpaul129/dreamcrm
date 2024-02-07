  class PosessionChargesController < ApplicationController
  before_action :set_posession_charge, only: [:show, :edit, :update, :destroy]

  # GET /posession_charges
  # GET /posession_charges.json
  def index
    @posession_charges = PosessionCharge.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  # GET /posession_charges/1
  # GET /posession_charges/1.json
  def show
  end

  # GET /posession_charges/new
  def new
    @posession_charge = PosessionCharge.new
    @extra_charges=selections(ExtraCharge,:description)
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
  end

  # GET /posession_charges/1/edit
  def edit
    @extra_charges=selections(ExtraCharge,:description)
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
  end

  # POST /posession_charges
  # POST /posession_charges.json
  def create
    @posession_charge = PosessionCharge.new(posession_charge_params)

    respond_to do |format|
      if @posession_charge.save
        format.html { redirect_to @posession_charge, notice: 'Posession charge was successfully created.' }
        format.json { render action: 'show', status: :created, location: @posession_charge }
      else
        format.html { render action: 'new' }
        format.json { render json: @posession_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posession_charges/1
  # PATCH/PUT /posession_charges/1.json
  def update
    respond_to do |format|
      if @posession_charge.update(posession_charge_params)
        format.html { redirect_to @posession_charge, notice: 'Posession charge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @posession_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posession_charges/1
  # DELETE /posession_charges/1.json
  def destroy
    @posession_charge.destroy
    respond_to do |format|
      format.html { redirect_to posession_charges_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_posession_charge
      @posession_charge = PosessionCharge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def posession_charge_params
      params.require(:posession_charge).permit(:block_id, :extra_charge_id, :amount, :rate)
    end
end
