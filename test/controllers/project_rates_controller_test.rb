require 'test_helper'

class ProjectRatesControllerTest < ActionController::TestCase
  setup do
    @project_rate = project_rates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_rates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_rate" do
    assert_difference('ProjectRate.count') do
      post :create, project_rate: { base_rate: @project_rate.base_rate, business_unit_id: @project_rate.business_unit_id, date: @project_rate.date }
    end

    assert_redirected_to project_rate_path(assigns(:project_rate))
  end

  test "should show project_rate" do
    get :show, id: @project_rate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_rate
    assert_response :success
  end

  test "should update project_rate" do
    patch :update, id: @project_rate, project_rate: { base_rate: @project_rate.base_rate, business_unit_id: @project_rate.business_unit_id, date: @project_rate.date }
    assert_redirected_to project_rate_path(assigns(:project_rate))
  end

  test "should destroy project_rate" do
    assert_difference('ProjectRate.count', -1) do
      delete :destroy, id: @project_rate
    end

    assert_redirected_to project_rates_path
  end
end
