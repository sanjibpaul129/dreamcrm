require 'test_helper'

class SourceCategoriesControllerTest < ActionController::TestCase
  setup do
    @source_category = source_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:source_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create source_category" do
    assert_difference('SourceCategory.count') do
      post :create, source_category: { description: @source_category.description, organisation_id: @source_category.organisation_id, predecessor: @source_category.predecessor }
    end

    assert_redirected_to source_category_path(assigns(:source_category))
  end

  test "should show source_category" do
    get :show, id: @source_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @source_category
    assert_response :success
  end

  test "should update source_category" do
    patch :update, id: @source_category, source_category: { description: @source_category.description, organisation_id: @source_category.organisation_id, predecessor: @source_category.predecessor }
    assert_redirected_to source_category_path(assigns(:source_category))
  end

  test "should destroy source_category" do
    assert_difference('SourceCategory.count', -1) do
      delete :destroy, id: @source_category
    end

    assert_redirected_to source_categories_path
  end
end
