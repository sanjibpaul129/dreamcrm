require 'test_helper'

class MarketingInstancesControllerTest < ActionController::TestCase
  setup do
    @marketing_instance = marketing_instances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:marketing_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create marketing_instance" do
    assert_difference('MarketingInstance.count') do
      post :create, marketing_instance: { business_unit_id: @marketing_instance.business_unit_id, description: @marketing_instance.description, quantity: @marketing_instance.quantity, rate: @marketing_instance.rate, source_category_id: @marketing_instance.source_category_id, tax: @marketing_instance.tax, work_order_id: @marketing_instance.work_order_id }
    end

    assert_redirected_to marketing_instance_path(assigns(:marketing_instance))
  end

  test "should show marketing_instance" do
    get :show, id: @marketing_instance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @marketing_instance
    assert_response :success
  end

  test "should update marketing_instance" do
    patch :update, id: @marketing_instance, marketing_instance: { business_unit_id: @marketing_instance.business_unit_id, description: @marketing_instance.description, quantity: @marketing_instance.quantity, rate: @marketing_instance.rate, source_category_id: @marketing_instance.source_category_id, tax: @marketing_instance.tax, work_order_id: @marketing_instance.work_order_id }
    assert_redirected_to marketing_instance_path(assigns(:marketing_instance))
  end

  test "should destroy marketing_instance" do
    assert_difference('MarketingInstance.count', -1) do
      delete :destroy, id: @marketing_instance
    end

    assert_redirected_to marketing_instances_path
  end
end
