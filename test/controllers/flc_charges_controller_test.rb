require 'test_helper'

class FlcChargesControllerTest < ActionController::TestCase
  setup do
    @flc_charge = flc_charges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flc_charges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flc_charge" do
    assert_difference('FlcCharge.count') do
      post :create, flc_charge: { block_id: @flc_charge.block_id, from_floor: @flc_charge.from_floor, rate: @flc_charge.rate }
    end

    assert_redirected_to flc_charge_path(assigns(:flc_charge))
  end

  test "should show flc_charge" do
    get :show, id: @flc_charge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @flc_charge
    assert_response :success
  end

  test "should update flc_charge" do
    patch :update, id: @flc_charge, flc_charge: { block_id: @flc_charge.block_id, from_floor: @flc_charge.from_floor, rate: @flc_charge.rate }
    assert_redirected_to flc_charge_path(assigns(:flc_charge))
  end

  test "should destroy flc_charge" do
    assert_difference('FlcCharge.count', -1) do
      delete :destroy, id: @flc_charge
    end

    assert_redirected_to flc_charges_path
  end
end
