require 'test_helper'

class BlockExtraChargesControllerTest < ActionController::TestCase
  setup do
    @block_extra_charge = block_extra_charges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:block_extra_charges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create block_extra_charge" do
    assert_difference('BlockExtraCharge.count') do
      post :create, block_extra_charge: { amount: @block_extra_charge.amount, block_id: @block_extra_charge.block_id, extra_charge_id: @block_extra_charge.extra_charge_id, flat_type: @block_extra_charge.flat_type, percentage: @block_extra_charge.percentage, rate: @block_extra_charge.rate }
    end

    assert_redirected_to block_extra_charge_path(assigns(:block_extra_charge))
  end

  test "should show block_extra_charge" do
    get :show, id: @block_extra_charge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @block_extra_charge
    assert_response :success
  end

  test "should update block_extra_charge" do
    patch :update, id: @block_extra_charge, block_extra_charge: { amount: @block_extra_charge.amount, block_id: @block_extra_charge.block_id, extra_charge_id: @block_extra_charge.extra_charge_id, flat_type: @block_extra_charge.flat_type, percentage: @block_extra_charge.percentage, rate: @block_extra_charge.rate }
    assert_redirected_to block_extra_charge_path(assigns(:block_extra_charge))
  end

  test "should destroy block_extra_charge" do
    assert_difference('BlockExtraCharge.count', -1) do
      delete :destroy, id: @block_extra_charge
    end

    assert_redirected_to block_extra_charges_path
  end
end
