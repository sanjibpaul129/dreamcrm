require 'test_helper'

class ExtraChargesControllerTest < ActionController::TestCase
  setup do
    @extra_charge = extra_charges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:extra_charges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create extra_charge" do
    assert_difference('ExtraCharge.count') do
      post :create, extra_charge: { description: @extra_charge.description, organisation_id: @extra_charge.organisation_id, service_tax: @extra_charge.service_tax }
    end

    assert_redirected_to extra_charge_path(assigns(:extra_charge))
  end

  test "should show extra_charge" do
    get :show, id: @extra_charge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @extra_charge
    assert_response :success
  end

  test "should update extra_charge" do
    patch :update, id: @extra_charge, extra_charge: { description: @extra_charge.description, organisation_id: @extra_charge.organisation_id, service_tax: @extra_charge.service_tax }
    assert_redirected_to extra_charge_path(assigns(:extra_charge))
  end

  test "should destroy extra_charge" do
    assert_difference('ExtraCharge.count', -1) do
      delete :destroy, id: @extra_charge
    end

    assert_redirected_to extra_charges_path
  end
end
