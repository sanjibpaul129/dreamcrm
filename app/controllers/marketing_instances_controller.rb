class MarketingInstancesController < ApplicationController
  before_action :set_marketing_instance, only: [:show, :edit, :update, :destroy]

  # GET /marketing_instances
  # GET /marketing_instances.json
  def index
    @marketing_instances = MarketingInstance.all
  end

  # GET /marketing_instances/1
  # GET /marketing_instances/1.json
  def show
  end

  # GET /marketing_instances/new
  def new
    @marketing_instance = MarketingInstance.new
  end

  # GET /marketing_instances/1/edit
  def edit
  end

  # POST /marketing_instances
  # POST /marketing_instances.json
  def create
    @marketing_instance = MarketingInstance.new(marketing_instance_params)

    respond_to do |format|
      if @marketing_instance.save
        format.html { redirect_to @marketing_instance, notice: 'Marketing instance was successfully created.' }
        format.json { render action: 'show', status: :created, location: @marketing_instance }
      else
        format.html { render action: 'new' }
        format.json { render json: @marketing_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marketing_instances/1
  # PATCH/PUT /marketing_instances/1.json
  def update
    respond_to do |format|
      if @marketing_instance.update(marketing_instance_params)
        format.html { redirect_to @marketing_instance, notice: 'Marketing instance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @marketing_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marketing_instances/1
  # DELETE /marketing_instances/1.json
  def destroy
    @marketing_instance.destroy
    respond_to do |format|
      format.html { redirect_to marketing_instances_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_marketing_instance
      @marketing_instance = MarketingInstance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def marketing_instance_params
      params.require(:marketing_instance).permit(:description, :business_unit_id, :source_category_id, :work_order_id, :rate, :quantity, :tax)
    end
end
