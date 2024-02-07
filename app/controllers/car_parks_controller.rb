class CarParksController < ApplicationController
  before_action :set_car_park, only: [:show, :edit, :update, :destroy]

  # GET /car_parks
  # GET /car_parks.json
  def index
    @car_parks = CarPark.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  # GET /car_parks/1
  # GET /car_parks/1.json
  def show
  end

  # GET /car_parks/new
  def new
    @car_park_natures=selections(CarParkNature,:description)
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end 
    @business_units=selections(BusinessUnit,:name)
    @car_park=CarPark.new
  end

  # GET /car_parks/1/edit
  def edit
    @car_park_natures=selections(CarParkNature,:description)
    @business_units=selections(BusinessUnit,:name)
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end 
  end

  # POST /car_parks
  # POST /car_parks.json
  def create
    @car_park = CarPark.new(car_park_params)
    
    respond_to do |format|
      if @car_park.save
        format.html { redirect_to @car_park, notice: 'Car park was successfully created.' }
        format.json { render action: 'show', status: :created, location: @car_park }
      else
        format.html { render action: 'new' }
        format.json { render json: @car_park.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /car_parks/1
  # PATCH/PUT /car_parks/1.json
  def update
    respond_to do |format|
      if @car_park.update(car_park_params)
        format.html { redirect_to @car_park, notice: 'Car park was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @car_park.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /car_parks/1
  # DELETE /car_parks/1.json
  def destroy
    @car_park.destroy
    respond_to do |format|
      format.html { redirect_to car_parks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_car_park
      @car_park = CarPark.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def car_park_params
      params.require(:car_park).permit(:car_park_nature_id, :block_id, :business_unit_id, :rate, :date)
    end
end
