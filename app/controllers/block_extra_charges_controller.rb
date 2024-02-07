class BlockExtraChargesController < ApplicationController
  before_action :set_block_extra_charge, only: [:show, :edit, :update, :destroy]

  # GET /block_extra_charges
  # GET /block_extra_charges.json
  def index
    @block_extra_charges = ExtraDevelopmentCharge.all
  end

  # GET /block_extra_charges/1
  # GET /block_extra_charges/1.json
  def show
  end

  # GET /block_extra_charges/new
  def new
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
    @block_extra_charge = ExtraDevelopmentCharge.new
    @extra_charges=selections(ExtraCharge, :description)

  end

  # GET /block_extra_charges/1/edit
  def edit
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
    @extra_charges=selections(ExtraCharge, :description)
  end

  # POST /block_extra_charges
  # POST /block_extra_charges.json
  def create
    @block_extra_charge = ExtraDevelopmentCharge.new(block_extra_charge_params)

    respond_to do |format|
      if @block_extra_charge.save
        format.html { redirect_to @block_extra_charge, notice: 'Block extra charge was successfully created.' }
        format.json { render action: 'show', status: :created, location: @block_extra_charge }
      else
        format.html { render action: 'new' }
        format.json { render json: @block_extra_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /block_extra_charges/1
  # PATCH/PUT /block_extra_charges/1.json
  def update
    respond_to do |format|
      if @block_extra_charge.update(block_extra_charge_params)
        format.html { redirect_to @block_extra_charge, notice: 'Block extra charge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @block_extra_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /block_extra_charges/1
  # DELETE /block_extra_charges/1.json
  def destroy
    @block_extra_charge.destroy
    respond_to do |format|
      format.html { redirect_to block_extra_charges_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_block_extra_charge
      @block_extra_charge = ExtraDevelopmentCharge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def block_extra_charge_params
      params.require(:block_extra_charge).permit(:block_id, :extra_charge_id, :percentage, :amount, :rate, :flat_type)
    end
end
