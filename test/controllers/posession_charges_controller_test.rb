require 'test_helper'

class PosessionChargesControllerTest < ActionController::TestCase
  setup do
    @posession_charge = posession_charges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:posession_charges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create posession_charge" do
    assert_difference('PosessionCharge.count') do
      post :create, posession_charge: { amount: @posession_charge.amount, block_id: @posession_charge.block_id, extra_charge_id: @posession_charge.extra_charge_id, rate: @posession_charge.rate }
    end

    assert_redirected_to posession_charge_path(assigns(:posession_charge))
  end

  test "should show posession_charge" do
    get :show, id: @posession_charge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @posession_charge
    assert_response :success
  end

  test "should update posession_charge" do
    patch :update, id: @posession_charge, posession_charge: { amount: @posession_charge.amount, block_id: @posession_charge.block_id, extra_charge_id: @posession_charge.extra_charge_id, rate: @posession_charge.rate }
    assert_redirected_to posession_charge_path(assigns(:posession_charge))
  end

  test "should destroy posession_charge" do
    assert_difference('PosessionCharge.count', -1) do
      delete :destroy, id: @posession_charge
    end

    assert_redirected_to posession_charges_path
  end
end
