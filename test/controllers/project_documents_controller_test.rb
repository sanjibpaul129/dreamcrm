require 'test_helper'

class ProjectDocumentsControllerTest < ActionController::TestCase
  setup do
    @project_document = project_documents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_documents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_document" do
    assert_difference('ProjectDocument.count') do
      post :create, project_document: { document_id: @project_document.document_id, link: @project_document.link, project_id: @project_document.project_id }
    end

    assert_redirected_to project_document_path(assigns(:project_document))
  end

  test "should show project_document" do
    get :show, id: @project_document
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_document
    assert_response :success
  end

  test "should update project_document" do
    patch :update, id: @project_document, project_document: { document_id: @project_document.document_id, link: @project_document.link, project_id: @project_document.project_id }
    assert_redirected_to project_document_path(assigns(:project_document))
  end

  test "should destroy project_document" do
    assert_difference('ProjectDocument.count', -1) do
      delete :destroy, id: @project_document
    end

    assert_redirected_to project_documents_path
  end
end
