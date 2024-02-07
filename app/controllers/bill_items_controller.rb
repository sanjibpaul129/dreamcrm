class BillItemsController < ApplicationController
  before_action :set_bill_item, only: [:show, :edit, :update, :destroy]

  # GET /bill_items
  # GET /bill_items.json
  def index
    @bill_items = BillItem.all
  end

  # GET /bill_items/1
  # GET /bill_items/1.json
  def show
  end

  # GET /bill_items/new
  def new
    @bill_item = BillItem.new
  end

  # GET /bill_items/1/edit
  def edit
  end

  # POST /bill_items
  # POST /bill_items.json
  def create
    @bill_item = BillItem.new(bill_item_params)

    respond_to do |format|
      if @bill_item.save
        format.html { redirect_to @bill_item, notice: 'Bill item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bill_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @bill_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bill_items/1
  # PATCH/PUT /bill_items/1.json
  def update
    respond_to do |format|
      if @bill_item.update(bill_item_params)
        format.html { redirect_to @bill_item, notice: 'Bill item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bill_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bill_items/1
  # DELETE /bill_items/1.json
  def destroy
    @bill_item.destroy
    respond_to do |format|
      format.html { redirect_to bill_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bill_item
      @bill_item = BillItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bill_item_params
      params.require(:bill_item).permit(:marketing_instance_id, :from, :to, :quantity, :status, :remarks, :bill_id)
    end
end
