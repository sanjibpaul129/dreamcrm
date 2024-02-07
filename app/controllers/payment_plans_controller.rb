class PaymentPlansController < ApplicationController
  before_action :set_payment_plan, only: [:show, :edit, :update, :destroy]

  # GET /payment_plans
  # GET /payment_plans.json
  def index
    @payment_plans = PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  # GET /payment_plans/1
  # GET /payment_plans/1.json
  def show
  end

  # GET /payment_plans/new
  def new
    @business_units=selections(BusinessUnit, :name)
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
    @payment_plan = PaymentPlan.new
  end

  # GET /payment_plans/1/edit
  def edit
    @business_units=selections(BusinessUnit, :name)
    @blocks=[['All', -1]]
    Block.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |block|
      @blocks+=[[block.business_unit.name+'-'+block.name,block.id]]
    end
  end

  # POST /payment_plans
  # POST /payment_plans.json
  def create         
    @payment_plan = PaymentPlan.new(payment_plan_params)

    respond_to do |format|
      if @payment_plan.save
        format.html { redirect_to @payment_plan, notice: 'Payment plan was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment_plan }
      else
        format.html { render action: 'new' }
        format.json { render json: @payment_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_plans/1
  # PATCH/PUT /payment_plans/1.json
  def update
    respond_to do |format|
      if @payment_plan.update(payment_plan_params)
        format.html { redirect_to @payment_plan, notice: 'Payment plan was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @payment_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_plans/1
  # DELETE /payment_plans/1.json
  def destroy
    @payment_plan.destroy
    respond_to do |format|
      format.html { redirect_to payment_plans_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_plan
      @payment_plan = PaymentPlan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_plan_params
      params.require(:payment_plan).permit(:block_id, :description, :business_unit_id)
    end
end
