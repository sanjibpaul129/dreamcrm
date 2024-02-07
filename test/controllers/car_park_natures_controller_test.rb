require 'test_helper'

class CarParkNaturesControllerTest < ActionController::TestCase
  setup do
    @car_park_nature = car_park_natures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:car_park_natures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create car_park_nature" do
    assert_difference('CarParkNature.count') do
      post :create, car_park_nature: { description: @car_park_nature.description, wheels: @car_park_nature.wheels }
    end

    assert_redirected_to car_park_nature_path(assigns(:car_park_nature))
  end

  test "should show car_park_nature" do
    get :show, id: @car_park_nature
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @car_park_nature
    assert_response :success
  end

  test "should update car_park_nature" do
    patch :update, id: @car_park_nature, car_park_nature: { description: @car_park_nature.description, wheels: @car_park_nature.wheels }
    assert_redirected_to car_park_nature_path(assigns(:car_park_nature))
  end

  test "should destroy car_park_nature" do
    assert_difference('CarParkNature.count', -1) do
      delete :destroy, id: @car_park_nature
    end

    assert_redirected_to car_park_natures_path
  end
end
