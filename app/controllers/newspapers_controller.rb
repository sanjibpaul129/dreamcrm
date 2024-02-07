class NewspapersController < ApplicationController
  before_action :set_newspaper, only: [:show, :edit, :update, :destroy]

  # GET /newspapers
  # GET /newspapers.json
  def index
    @newspapers = Newspaper.all
  end

  # GET /newspapers/1
  # GET /newspapers/1.json
  def show
  end

  # GET /newspapers/new
  def new
    @newspaper = Newspaper.new
  end

  # GET /newspapers/1/edit
  def edit
  end

  # POST /newspapers
  # POST /newspapers.json
  def create
    @newspaper = Newspaper.new(newspaper_params)
    @newspaper.organisation_id = current_personnel.organisation_id
    @newspaper.save

    redirect_to newspapers_url
  end

  # PATCH/PUT /newspapers/1
  # PATCH/PUT /newspapers/1.json
  def update
    @newspaper.update(newspaper_params)

    redirect_to newspapers_url
  end

  # DELETE /newspapers/1
  # DELETE /newspapers/1.json
  def destroy
    @newspaper.destroy
    respond_to do |format|
      format.html { redirect_to newspapers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_newspaper
      @newspaper = Newspaper.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def newspaper_params
      params.require(:newspaper).permit(:description)
    end
end
