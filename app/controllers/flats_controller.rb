class FlatsController < ApplicationController
  before_action :set_flat, only: [:show, :edit, :update, :destroy]

  # GET /flats
  # GET /flats.json
  def index
    if params[:flat_index] == nil
    @selected_business_unit_id=BusinessUnit.where(organisation_id: current_personnel.organisation_id)[0].id
    else
      @selected_business_unit_id=params[:flat_index][:business_unit_id]
    end
    @flats = Flat.includes(:block => [:business_unit]).where(:blocks => {business_unit_id: @selected_business_unit_id})
    @business_units=selectoptions(BusinessUnit, :name)
    # @blocks=selectoptions(Block, :name)
  end



  # GET /flats/1
  # GET /flats/1.json
  def show
  end

  # GET /flats/new
  def new
    @flat = Flat.new
    @blocks=[]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
  end

  # GET /flats/1/edit
  def edit
    @blocks=[]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
  end

  # POST /flats
  # POST /flats.json
  def create
    @flat = Flat.new(flat_params)

    respond_to do |format|
      if @flat.save
        format.html { redirect_to @flat, notice: 'Flat was successfully created.' }
        format.json { render action: 'show', status: :created, location: @flat }
      else
        format.html { render action: 'new' }
        format.json { render json: @flat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flats/1
  # PATCH/PUT /flats/1.json
  def update
    respond_to do |format|
      if @flat.update(flat_params)
        format.html { redirect_to @flat, notice: 'Flat was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @flat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flats/1
  # DELETE /flats/1.json
  def destroy
    @flat.destroy
    respond_to do |format|
      format.html { redirect_to flat_index_flat_index_url }
      format.json { head :no_content }
    end
  end

  def flat_index
    if params[:flat_index] == nil
      @selected_block_id=Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})[0].id
    else
      @selected_block_id=params[:flat_index][:block_id]
    end
    @flats = Flat.includes(:block => [:business_unit]).where(:blocks => {id: @selected_block_id})
    @blocks=[]
    BusinessUnit.where(organisation_id: current_personnel.organisation_id).each do |business_unit|
      business_unit.blocks.each do |block|
        @blocks+=[[block.business_unit.name+'-'+block.name, block.id]]
      end
    end
  end

  def opening_balance_index
    if params[:business_unit]==nil
      @flats=Flat.includes(:block =>[:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id, name: 'Dream Exotica'}).where.not(lead_id: nil)
      @business_units=selections(BusinessUnit, :name)
      @business_unit_id=BusinessUnit.find_by_name('Dream Exotica').id
    else
      @business_unit_id=params[:business_unit][:business_unit_id]
      @business_units=selections(BusinessUnit, :name)
      @flats=Flat.includes(:block =>[:business_unit]).where(:business_units => {id: @business_unit_id.to_i, organisation_id: current_personnel.organisation_id}).where.not(lead_id: nil)
    end
  end

  def opening_balance_edit
    @flat=Flat.find(params[:format])
  end

  def opening_balance_update
    @flat= Flat.find(params[:flat_id])
    @flat.update(opening_balance: params[:flat][:opening_balance])

    flash[:success]='Opening Balance updated successfully.'
    redirect_to flats_opening_balance_index_url    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flat
      @flat = Flat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flat_params
      params.require(:flat).permit(:block_id, :floor, :name, :status, :SBA, :OTA, :flat_bua, :ot_bua, :flat_bua_markup, :ot_bua_markdown, :bathrooms, :balconies, :business_unit_id, :land_area, :price, :second_floor_built_up, :first_floor_built_up, :first_floor_balcony_built_up, :ground_floor_built_up, :second_floor_carpet, :first_floor_carpet, :ground_floor_carpet, :first_floor_balcony_carpet, :ot_bua, :ot_carpet, :carpet_area, :BHK)
    end
end
