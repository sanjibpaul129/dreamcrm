require 'test_helper'

class MarketingNumbersControllerTest < ActionController::TestCase
  setup do
    @marketing_number = marketing_numbers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:marketing_numbers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create marketing_number" do
    assert_difference('MarketingNumber.count') do
      post :create, marketing_number: { number: @marketing_number.number, organisation_id: @marketing_number.organisation_id }
    end

    assert_redirected_to marketing_number_path(assigns(:marketing_number))
  end

  test "should show marketing_number" do
    get :show, id: @marketing_number
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @marketing_number
    assert_response :success
  end

  test "should update marketing_number" do
    patch :update, id: @marketing_number, marketing_number: { number: @marketing_number.number, organisation_id: @marketing_number.organisation_id }
    assert_redirected_to marketing_number_path(assigns(:marketing_number))
  end

  test "should destroy marketing_number" do
    assert_difference('MarketingNumber.count', -1) do
      delete :destroy, id: @marketing_number
    end

    assert_redirected_to marketing_numbers_path
  end
end
