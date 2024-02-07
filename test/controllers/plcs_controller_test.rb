require 'test_helper'

class PlcsControllerTest < ActionController::TestCase
  setup do
    @plc = plcs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plcs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plc" do
    assert_difference('Plc.count') do
      post :create, plc: { name: @plc.name, organisation_id: @plc.organisation_id }
    end

    assert_redirected_to plc_path(assigns(:plc))
  end

  test "should show plc" do
    get :show, id: @plc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plc
    assert_response :success
  end

  test "should update plc" do
    patch :update, id: @plc, plc: { name: @plc.name, organisation_id: @plc.organisation_id }
    assert_redirected_to plc_path(assigns(:plc))
  end

  test "should destroy plc" do
    assert_difference('Plc.count', -1) do
      delete :destroy, id: @plc
    end

    assert_redirected_to plcs_path
  end
end
