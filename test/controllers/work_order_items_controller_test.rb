require 'test_helper'

class WorkOrderItemsControllerTest < ActionController::TestCase
  setup do
    @work_order_item = work_order_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_order_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_order_item" do
    assert_difference('WorkOrderItem.count') do
      post :create, work_order_item: { marketing_instance_id: @work_order_item.marketing_instance_id, quantity: @work_order_item.quantity, rate: @work_order_item.rate, remarks: @work_order_item.remarks, tax: @work_order_item.tax, work_order_id: @work_order_item.work_order_id }
    end

    assert_redirected_to work_order_item_path(assigns(:work_order_item))
  end

  test "should show work_order_item" do
    get :show, id: @work_order_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @work_order_item
    assert_response :success
  end

  test "should update work_order_item" do
    patch :update, id: @work_order_item, work_order_item: { marketing_instance_id: @work_order_item.marketing_instance_id, quantity: @work_order_item.quantity, rate: @work_order_item.rate, remarks: @work_order_item.remarks, tax: @work_order_item.tax, work_order_id: @work_order_item.work_order_id }
    assert_redirected_to work_order_item_path(assigns(:work_order_item))
  end

  test "should destroy work_order_item" do
    assert_difference('WorkOrderItem.count', -1) do
      delete :destroy, id: @work_order_item
    end

    assert_redirected_to work_order_items_path
  end
end
