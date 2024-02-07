class LostReasonsController < ApplicationController
  before_action :set_lost_reason, only: [:show, :edit, :update, :destroy]

  # GET /lost_reasons
  # GET /lost_reasons.json
  def index
    @lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id)
  end

  # GET /lost_reasons/1
  # GET /lost_reasons/1.json
  def show
  end

  # GET /lost_reasons/new
  def new
    @lost_reason = LostReason.new
  end

  # GET /lost_reasons/1/edit
  def edit
  end

  # POST /lost_reasons
  # POST /lost_reasons.json
  def create
    @lost_reason = LostReason.new(lost_reason_params)
    @lost_reason.organisation_id=current_personnel.organisation_id
    respond_to do |format|
      if @lost_reason.save
        format.html { redirect_to @lost_reason, notice: 'Lost reason was successfully created.' }
        format.json { render action: 'show', status: :created, location: @lost_reason }
      else
        format.html { render action: 'new' }
        format.json { render json: @lost_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lost_reasons/1
  # PATCH/PUT /lost_reasons/1.json
  def update
    respond_to do |format|
      if @lost_reason.update(lost_reason_params)
        format.html { redirect_to @lost_reason, notice: 'Lost reason was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @lost_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lost_reasons/1
  # DELETE /lost_reasons/1.json
  def destroy
    @lost_reason.destroy
    respond_to do |format|
      format.html { redirect_to lost_reasons_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lost_reason
      @lost_reason = LostReason.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lost_reason_params
      params.require(:lost_reason).permit(:description, :organisation_id)
    end
end
