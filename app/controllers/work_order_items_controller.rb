class WorkOrderItemsController < ApplicationController
  before_action :set_work_order_item, only: [:show, :edit, :update, :destroy]

  # GET /work_order_items
  # GET /work_order_items.json
  def index
    @work_order_items = WorkOrderItem.all
  end

  # GET /work_order_items/1
  # GET /work_order_items/1.json
  def show
  end

  # GET /work_order_items/new
  def new
    @work_order_item = WorkOrderItem.new
  end

  # GET /work_order_items/1/edit
  def edit
  end

  # POST /work_order_items
  # POST /work_order_items.json
  def create
    @work_order_item = WorkOrderItem.new(work_order_item_params)

    respond_to do |format|
      if @work_order_item.save
        format.html { redirect_to @work_order_item, notice: 'Work order item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @work_order_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @work_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_order_items/1
  # PATCH/PUT /work_order_items/1.json
  def update
    respond_to do |format|
      if @work_order_item.update(work_order_item_params)
        format.html { redirect_to @work_order_item, notice: 'Work order item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @work_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_order_items/1
  # DELETE /work_order_items/1.json
  def destroy
    @work_order_item.destroy
    respond_to do |format|
      format.html { redirect_to work_order_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_order_item
      @work_order_item = WorkOrderItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_order_item_params
      params.require(:work_order_item).permit(:marketing_instance_id, :work_order_id, :rate, :quantity, :tax, :remarks)
    end
end
