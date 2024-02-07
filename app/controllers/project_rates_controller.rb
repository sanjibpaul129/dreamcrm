class ProjectRatesController < ApplicationController
  before_action :set_project_rate, only: [:show, :edit, :update, :destroy]

  # GET /project_rates
  # GET /project_rates.json
  def index
    @project_rates = ProjectRate.all
  end

  # GET /project_rates/1
  # GET /project_rates/1.json
  def show
  end

  # GET /project_rates/new
  def new
    @project_rate = ProjectRate.new
  end

  # GET /project_rates/1/edit
  def edit
  end

  # POST /project_rates
  # POST /project_rates.json
  def create
    @project_rate = ProjectRate.new(project_rate_params)

    respond_to do |format|
      if @project_rate.save
        format.html { redirect_to @project_rate, notice: 'Project rate was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project_rate }
      else
        format.html { render action: 'new' }
        format.json { render json: @project_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /project_rates/1
  # PATCH/PUT /project_rates/1.json
  def update
    respond_to do |format|
      if @project_rate.update(project_rate_params)
        format.html { redirect_to @project_rate, notice: 'Project rate was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project_rates/1
  # DELETE /project_rates/1.json
  def destroy
    @project_rate.destroy
    respond_to do |format|
      format.html { redirect_to project_rates_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project_rate
      @project_rate = ProjectRate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_rate_params
      params.require(:project_rate).permit(:business_unit_id, :base_rate, :date)
    end
end
