class MilestonesController < ApplicationController
  before_action :set_milestone, only: [:show, :edit, :update, :destroy]

  # GET /milestones
  # GET /milestones.json
  def index
    @payment_plans=[]
    PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |payment_plan|
      @payment_plans+=[[payment_plan.description, payment_plan.id]]
    end
    @milestones = Milestone.includes(:payment_plan => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  def milestone_index
    @payment_plans=[]
    PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |payment_plan|
      @payment_plans+=[[payment_plan.description, payment_plan.id]]
    end
    if params[:payment_plan_id]==nil
      @milestones = Milestone.includes(:payment_plan => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id})
      @payment_plan_id=0
    else
      @payment_plan_id = params[:payment_plan_id]
      @milestones = Milestone.includes(:payment_plan => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}, :payment_plans => {id: @payment_plan_id.to_i})
    end
  end

  # GET /milestones/1
  # GET /milestones/1.json
  def show
  end

  # GET /milestones/new
  def new
    @milestone = Milestone.new
    @payment_milestone=selections(PaymentMilestone, :description)
    @payment_plans=[['All', -1]]
    PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |payment_plan|
      @payment_plans+=[[payment_plan.business_unit.name+'-'+payment_plan.description,payment_plan.id]]
    end
  end

  # GET /milestones/1/edit
  def edit
    @payment_milestone=selections(PaymentMilestone, :description)
    @payment_plans=[['All', -1]]
    PaymentPlan.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id}).each do |payment_plan|
      @payment_plans+=[[payment_plan.business_unit.name+'-'+payment_plan.description,payment_plan.id]]
    end
  end

  # POST /milestones
  # POST /milestones.json
  def create
    @milestone = Milestone.new(milestone_params)

    respond_to do |format|
      if @milestone.save
        format.html { redirect_to @milestone, notice: 'Milestone was successfully created.' }
        format.json { render action: 'show', status: :created, location: @milestone }
      else
        format.html { render action: 'new' }
        format.json { render json: @milestone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /milestones/1
  # PATCH/PUT /milestones/1.json
  def update
    respond_to do |format|
      if @milestone.update(milestone_params)
        format.html { redirect_to @milestone, notice: 'Milestone was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @milestone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /milestones/1
  # DELETE /milestones/1.json
  def destroy
    @milestone.destroy
    respond_to do |format|
      format.html { redirect_to milestones_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_milestone
      @milestone = Milestone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def milestone_params
      params.require(:milestone).permit(:name, :flat_value_percentage, :extra_development_charge_percentage, :extra_charge_id, :amount,:order,:nature, :payment_plan_id,:payment_milestone_id)
    end
end
