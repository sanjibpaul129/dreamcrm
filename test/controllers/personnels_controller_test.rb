require 'test_helper'

class PersonnelsControllerTest < ActionController::TestCase
  setup do
    @personnel = personnels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:personnels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create personnel" do
    assert_difference('Personnel.count') do
      post :create, personnel: { auth_token: @personnel.auth_token, email: @personnel.email, mobile: @personnel.mobile, name: @personnel.name, password_reset_sent_at: @personnel.password_reset_sent_at, password_reset_token: @personnel.password_reset_token, passwordhash: @personnel.passwordhash, passwordsalt: @personnel.passwordsalt }
    end

    assert_redirected_to personnel_path(assigns(:personnel))
  end

  test "should show personnel" do
    get :show, id: @personnel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @personnel
    assert_response :success
  end

  test "should update personnel" do
    patch :update, id: @personnel, personnel: { auth_token: @personnel.auth_token, email: @personnel.email, mobile: @personnel.mobile, name: @personnel.name, password_reset_sent_at: @personnel.password_reset_sent_at, password_reset_token: @personnel.password_reset_token, passwordhash: @personnel.passwordhash, passwordsalt: @personnel.passwordsalt }
    assert_redirected_to personnel_path(assigns(:personnel))
  end

  test "should destroy personnel" do
    assert_difference('Personnel.count', -1) do
      delete :destroy, id: @personnel
    end

    assert_redirected_to personnels_path
  end
end
