class PreferredLocationsController < ApplicationController
  before_action :set_preferred_location, only: [:show, :edit, :update, :destroy]

  # GET /preferred_locations
  # GET /preferred_locations.json
  def index
    @preferred_locations = PreferredLocation.where(organisation_id: current_personnel.organisation_id)
  end

  # GET /preferred_locations/1
  # GET /preferred_locations/1.json
  def show
  end

  # GET /preferred_locations/new
  def new
    @preferred_location = PreferredLocation.new
  end

  # GET /preferred_locations/1/edit
  def edit
  end

  # POST /preferred_locations
  # POST /preferred_locations.json
  def create
    @preferred_location = PreferredLocation.new(preferred_location_params)
    @preferred_location.organisation_id = current_personnel.organisation_id
    @preferred_location.save

    redirect_to preferred_locations_url
  end

  # PATCH/PUT /preferred_locations/1
  # PATCH/PUT /preferred_locations/1.json
  def update
    @preferred_location.update(preferred_location_params)

    redirect_to preferred_locations_url
  end

  # DELETE /preferred_locations/1
  # DELETE /preferred_locations/1.json
  def destroy
    @preferred_location.destroy
    respond_to do |format|
      format.html { redirect_to preferred_locations_url }
      format.json { head :no_content }
    end
  end

  def preferred_location_tag_index
    # @preferred_location_tags=PreferredLocationTag.includes(:preferred_location, :lead).where(:preferred_locations => {organisation_id: current_personnel.organisation_id})
    @preferred_location_tags=PreferredLocationTag.all
  end

  def preferred_location_tag_new
    @preferred_location_tag=PreferredLocationTag.new
    @preferred_locations=selections(PreferredLocation, :description)
    @leads=Lead.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
    @all_customers=[]
    @leads.each do |lead|
      @all_customers+=[lead.name, lead.id]
    end
  end

  def preferred_location_tag_create
  end

  def preferred_location_tag_edit
  end

  def preferred_location_tag_update
  end

  def preferred_location_tag_destroy
  end





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_preferred_location
      @preferred_location = PreferredLocation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def preferred_location_params
      params.require(:preferred_location).permit(:description)
    end
end
