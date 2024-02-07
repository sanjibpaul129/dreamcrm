class NationalitiesController < ApplicationController
  before_action :set_nationality, only: [:show, :edit, :update, :destroy]

  # GET /nationalities
  # GET /nationalities.json
  def index
    @nationalities = Nationality.all
  end

  # GET /nationalities/1
  # GET /nationalities/1.json
  def show
  end

  # GET /nationalities/new
  def new
    @nationality = Nationality.new
  end

  # GET /nationalities/1/edit
  def edit
  end

  # POST /nationalities
  # POST /nationalities.json
  def create
    @nationality = Nationality.new(nationality_params)
    @nationality.organisation_id = current_personnel.organisation_id
    @nationality.save

    redirect_to nationalities_url
  end

  # PATCH/PUT /nationalities/1
  # PATCH/PUT /nationalities/1.json
  def update
    @nationality.update(nationality_params)

    redirect_to nationalities_url
  end

  # DELETE /nationalities/1
  # DELETE /nationalities/1.json
  def destroy
    @nationality.destroy
    respond_to do |format|
      format.html { redirect_to nationalities_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nationality
      @nationality = Nationality.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nationality_params
      params.require(:nationality).permit(:description, :organisation_id)
    end
end
