class DesignationsController < ApplicationController
  before_action :set_designation, only: [:show, :edit, :update, :destroy]

  # GET /designations
  # GET /designations.json
  def index
    @designations = Designation.all
  end

  # GET /designations/1
  # GET /designations/1.json
  def show
  end

  # GET /designations/new
  def new
    @designation = Designation.new
  end

  # GET /designations/1/edit
  def edit
  end

  # POST /designations
  # POST /designations.json
  def create
    @designation = Designation.new(designation_params)
    @designation.organisation_id = current_personnel.organisation_id
    @designation.save

    redirect_to designations_url
    # respond_to do |format|
    #   if 
    #     format.html { redirect_to @designation, notice: 'designation was successfully created.' }
    #     format.json { render action: 'show', status: :created, location: @designation }
    #   else
    #     format.html { render action: 'new' }
    #     format.json { render json: @designation.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /designations/1
  # PATCH/PUT /designations/1.json
  def update
    @designation.update(designation_params)

    redirect_to designations_url
  end

  # DELETE /designation/1
  # DELETE /designation/1.json
  def destroy
    @designation.destroy
     redirect_to designations_url
    # respond_to do |format|
    #   format.html { redirect_to designation_url }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_designation
      @designation = Designation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def designation_params
      params.require(:designation).permit(:description)
    end
end
