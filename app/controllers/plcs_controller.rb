class PlcsController < ApplicationController
  before_action :set_plc, only: [:show, :edit, :update, :destroy]

  # GET /plcs
  # GET /plcs.json
  def index
    @plcs = Plc.where(organisation_id: current_personnel.organisation_id)
  end

  # GET /plcs/1
  # GET /plcs/1.json
  def show
  end

  # GET /plcs/new
  def new
    # @organisations=selectoptions(Organisation, :name)
    @plc = Plc.new
  end

  # GET /plcs/1/edit
  def edit
    # @organisations=selectoptions(Organisation, :name)
  end

  # POST /plcs
  # POST /plcs.json
  def create
    
    @plc = Plc.new(plc_params)
    @plc.organisation_id=current_personnel.organisation_id
    respond_to do |format|
      if @plc.save
        format.html { redirect_to @plc, notice: 'Plc was successfully created.' }
        format.json { render action: 'show', status: :created, location: @plc }
      else
        format.html { render action: 'new' }
        format.json { render json: @plc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plcs/1
  # PATCH/PUT /plcs/1.json
  def update
    respond_to do |format|
      if @plc.update(plc_params)
        format.html { redirect_to @plc, notice: 'Plc was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @plc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plcs/1
  # DELETE /plcs/1.json
  def destroy
    @plc.destroy
    respond_to do |format|
      format.html { redirect_to plcs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plc
      @plc = Plc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plc_params
      params.require(:plc).permit(:name)
    end
end
