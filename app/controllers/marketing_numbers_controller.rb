class MarketingNumbersController < ApplicationController
  before_action :set_marketing_number, only: [:show, :edit, :update, :destroy]

  # GET /marketing_numbers
  # GET /marketing_numbers.json
  def index
    @marketing_numbers = MarketingNumber.all
  end

  # GET /marketing_numbers/1
  # GET /marketing_numbers/1.json
  def show
  end

  # GET /marketing_numbers/new
  def new
    @marketing_number = MarketingNumber.new
  end

  # GET /marketing_numbers/1/edit
  def edit
  end

  # POST /marketing_numbers
  # POST /marketing_numbers.json
  def create
    @marketing_number = MarketingNumber.new(marketing_number_params)

    respond_to do |format|
      if @marketing_number.save
        format.html { redirect_to @marketing_number, notice: 'Marketing number was successfully created.' }
        format.json { render action: 'show', status: :created, location: @marketing_number }
      else
        format.html { render action: 'new' }
        format.json { render json: @marketing_number.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marketing_numbers/1
  # PATCH/PUT /marketing_numbers/1.json
  def update
    respond_to do |format|
      if @marketing_number.update(marketing_number_params)
        format.html { redirect_to @marketing_number, notice: 'Marketing number was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @marketing_number.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marketing_numbers/1
  # DELETE /marketing_numbers/1.json
  def destroy
    @marketing_number.destroy
    respond_to do |format|
      format.html { redirect_to marketing_numbers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_marketing_number
      @marketing_number = MarketingNumber.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def marketing_number_params
      params.require(:marketing_number).permit(:number, :organisation_id)
    end
end
