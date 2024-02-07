class CarParkNaturesController < ApplicationController
  before_action :set_car_park_nature, only: [:show, :edit, :update, :destroy]

  # GET /car_park_natures
  # GET /car_park_natures.json
  def index
    @car_park_natures = CarParkNature.where(organisation_id: current_personnel.organisation_id)
  end

  # GET /car_park_natures/1
  # GET /car_park_natures/1.json
  def show
  end

  # GET /car_park_natures/new
  def new
    @car_park_nature = CarParkNature.new
  end

  # GET /car_park_natures/1/edit
  def edit
  end

  # POST /car_park_natures
  # POST /car_park_natures.json
  def create
    @car_park_nature = CarParkNature.new(car_park_nature_params)
    @car_park_nature.organisation_id=current_personnel.organisation_id
    respond_to do |format|
      if @car_park_nature.save
        format.html { redirect_to @car_park_nature, notice: 'Car park nature was successfully created.' }
        format.json { render action: 'show', status: :created, location: @car_park_nature }
      else
        format.html { render action: 'new' }
        format.json { render json: @car_park_nature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /car_park_natures/1
  # PATCH/PUT /car_park_natures/1.json
  def update
    respond_to do |format|
      if @car_park_nature.update(car_park_nature_params)
        format.html { redirect_to @car_park_nature, notice: 'Car park nature was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @car_park_nature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /car_park_natures/1
  # DELETE /car_park_natures/1.json
  def destroy
    @car_park_nature.destroy
    respond_to do |format|
      format.html { redirect_to car_park_natures_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_car_park_nature
      @car_park_nature = CarParkNature.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def car_park_nature_params
      params.require(:car_park_nature).permit(:wheels, :description)
    end
end
