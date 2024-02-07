require 'test_helper'

class BusinessUnitsControllerTest < ActionController::TestCase
  setup do
    @business_unit = business_units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:business_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create business_unit" do
    assert_difference('BusinessUnit.count') do
      post :create, business_unit: { address_1: @business_unit.address_1, address_2: @business_unit.address_2, address_3: @business_unit.address_3, address_4: @business_unit.address_4, company_id: @business_unit.company_id, email: @business_unit.email, logo: @business_unit.logo, name: @business_unit.name, organisation_id: @business_unit.organisation_id, shortform: @business_unit.shortform }
    end

    assert_redirected_to business_unit_path(assigns(:business_unit))
  end

  test "should show business_unit" do
    get :show, id: @business_unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @business_unit
    assert_response :success
  end

  test "should update business_unit" do
    patch :update, id: @business_unit, business_unit: { address_1: @business_unit.address_1, address_2: @business_unit.address_2, address_3: @business_unit.address_3, address_4: @business_unit.address_4, company_id: @business_unit.company_id, email: @business_unit.email, logo: @business_unit.logo, name: @business_unit.name, organisation_id: @business_unit.organisation_id, shortform: @business_unit.shortform }
    assert_redirected_to business_unit_path(assigns(:business_unit))
  end

  test "should destroy business_unit" do
    assert_difference('BusinessUnit.count', -1) do
      delete :destroy, id: @business_unit
    end

    assert_redirected_to business_units_path
  end
end
