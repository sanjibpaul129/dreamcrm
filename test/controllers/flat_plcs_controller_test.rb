require 'test_helper'

class FlatPlcsControllerTest < ActionController::TestCase
  setup do
    @flat_plc = flat_plcs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flat_plcs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flat_plc" do
    assert_difference('FlatPlc.count') do
      post :create, flat_plc: { flat_id: @flat_plc.flat_id, plc_charge_id: @flat_plc.plc_charge_id }
    end

    assert_redirected_to flat_plc_path(assigns(:flat_plc))
  end

  test "should show flat_plc" do
    get :show, id: @flat_plc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @flat_plc
    assert_response :success
  end

  test "should update flat_plc" do
    patch :update, id: @flat_plc, flat_plc: { flat_id: @flat_plc.flat_id, plc_charge_id: @flat_plc.plc_charge_id }
    assert_redirected_to flat_plc_path(assigns(:flat_plc))
  end

  test "should destroy flat_plc" do
    assert_difference('FlatPlc.count', -1) do
      delete :destroy, id: @flat_plc
    end

    assert_redirected_to flat_plcs_path
  end
end
