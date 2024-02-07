class FlatPlcsController < ApplicationController
  before_action :set_flat_plc, only: [:show, :edit, :update, :destroy]

  # GET /flat_plcs
  # GET /flat_plcs.json
  def index
    @flat_plcs = FlatPlc.all
  end

  # GET /flat_plcs/1
  # GET /flat_plcs/1.json
  def show
  end

  # GET /flat_plcs/new
  def new
    @flat_plc = FlatPlc.new
    @flats=selectoptions(Flat,:name)
    @plc_charges=[]
      PlcCharge.includes(:plc, :block).where(:plcs => {organisation_id: current_personnel.organisation_id}).each do |plc_charge|
        @plc_charges+=[[plc_charge.plc.name+'-'+plc_charge.block.name, plc_charge.id]]
      end
  end

  # GET /flat_plcs/1/edit
  def edit
  end

  # POST /flat_plcs
  # POST /flat_plcs.json
  def create
    @flat_plc = FlatPlc.new(flat_plc_params)

    respond_to do |format|
      if @flat_plc.save
        format.html { redirect_to @flat_plc, notice: 'Flat plc was successfully created.' }
        format.json { render action: 'show', status: :created, location: @flat_plc }
      else
        format.html { render action: 'new' }
        format.json { render json: @flat_plc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flat_plcs/1
  # PATCH/PUT /flat_plcs/1.json
  def update
    respond_to do |format|
      if @flat_plc.update(flat_plc_params)
        format.html { redirect_to @flat_plc, notice: 'Flat plc was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @flat_plc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flat_plcs/1
  # DELETE /flat_plcs/1.json
  def destroy
    @flat_plc.destroy
    respond_to do |format|
      format.html { redirect_to flat_plcs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flat_plc
      @flat_plc = FlatPlc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flat_plc_params
      params.require(:flat_plc).permit(:flat_id, :plc_charge_id)
    end
end
