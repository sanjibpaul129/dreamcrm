require 'test_helper'

class LostReasonsControllerTest < ActionController::TestCase
  setup do
    @lost_reason = lost_reasons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lost_reasons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lost_reason" do
    assert_difference('LostReason.count') do
      post :create, lost_reason: { description: @lost_reason.description, organisation_id: @lost_reason.organisation_id }
    end

    assert_redirected_to lost_reason_path(assigns(:lost_reason))
  end

  test "should show lost_reason" do
    get :show, id: @lost_reason
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lost_reason
    assert_response :success
  end

  test "should update lost_reason" do
    patch :update, id: @lost_reason, lost_reason: { description: @lost_reason.description, organisation_id: @lost_reason.organisation_id }
    assert_redirected_to lost_reason_path(assigns(:lost_reason))
  end

  test "should destroy lost_reason" do
    assert_difference('LostReason.count', -1) do
      delete :destroy, id: @lost_reason
    end

    assert_redirected_to lost_reasons_path
  end
end
