require 'test_helper'

class PreferredLocationsControllerTest < ActionController::TestCase
  setup do
    @preferred_location = preferred_locations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:preferred_locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create preferred_location" do
    assert_difference('PreferredLocation.count') do
      post :create, preferred_location: { description: @preferred_location.description, organisation_id: @preferred_location.organisation_id }
    end

    assert_redirected_to preferred_location_path(assigns(:preferred_location))
  end

  test "should show preferred_location" do
    get :show, id: @preferred_location
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @preferred_location
    assert_response :success
  end

  test "should update preferred_location" do
    patch :update, id: @preferred_location, preferred_location: { description: @preferred_location.description, organisation_id: @preferred_location.organisation_id }
    assert_redirected_to preferred_location_path(assigns(:preferred_location))
  end

  test "should destroy preferred_location" do
    assert_difference('PreferredLocation.count', -1) do
      delete :destroy, id: @preferred_location
    end

    assert_redirected_to preferred_locations_path
  end
end
