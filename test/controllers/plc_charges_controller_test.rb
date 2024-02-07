require 'test_helper'

class PlcChargesControllerTest < ActionController::TestCase
  setup do
    @plc_charge = plc_charges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plc_charges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plc_charge" do
    assert_difference('PlcCharge.count') do
      post :create, plc_charge: { block_id: @plc_charge.block_id, plc_id: @plc_charge.plc_id, rate: @plc_charge.rate }
    end

    assert_redirected_to plc_charge_path(assigns(:plc_charge))
  end

  test "should show plc_charge" do
    get :show, id: @plc_charge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plc_charge
    assert_response :success
  end

  test "should update plc_charge" do
    patch :update, id: @plc_charge, plc_charge: { block_id: @plc_charge.block_id, plc_id: @plc_charge.plc_id, rate: @plc_charge.rate }
    assert_redirected_to plc_charge_path(assigns(:plc_charge))
  end

  test "should destroy plc_charge" do
    assert_difference('PlcCharge.count', -1) do
      delete :destroy, id: @plc_charge
    end

    assert_redirected_to plc_charges_path
  end
end
